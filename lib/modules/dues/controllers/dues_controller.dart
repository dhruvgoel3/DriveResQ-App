import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driveresq_app/app/routes/app_pages.dart';
import 'package:driveresq_app/modules/dues/models/platform_due.dart';
import 'package:driveresq_app/modules/dues/services/dues_service.dart';
import 'package:driveresq_app/modules/dues/services/razorpay_checkout_service.dart';
import 'package:driveresq_app/shared/services/connectivity_service.dart';
import 'package:driveresq_app/shared/services/error_handler.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';

class DuesController extends GetxController {
  final RxDouble outstanding = 0.0.obs;
  final RxString accountStatus = 'active'.obs;
  final RxnString suspendedReason = RxnString();
  final RxList<PlatformDue> duesList = <PlatformDue>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isPaying = false.obs;

  StreamSubscription? _duesSub;
  StreamSubscription? _userSub;

  late final RazorpayCheckoutService _checkoutService;

  bool get isSuspended =>
      accountStatus.value == 'suspended' || outstanding.value > 0;

  @override
  void onInit() {
    super.onInit();
    _checkoutService = RazorpayCheckoutService();
    _initStreams();
  }

  void _initStreams() {
    isLoading.value = true;

    // Proactively backfill any prior completed jobs that lacked ledger entries
    DuesService.syncPendingDues();

    _userSub = DuesService.streamOutstanding().listen(
      (data) {
        if (data != null) {
          outstanding.value =
              (data['platformDueOutstanding'] as num?)?.toDouble() ?? 0.0;
          accountStatus.value =
              (data['accountStatus'] as String?) ?? 'active';
          suspendedReason.value = data['suspendedReason'] as String?;
        }
      },
      onError: (err) {
        debugPrint('[DuesController] Error listening to user status: $err');
      },
    );

    _duesSub = DuesService.streamMyDues().listen(
      (list) {
        duesList.assignAll(list);
        isLoading.value = false;
      },
      onError: (err) {
        debugPrint('[DuesController] Error listening to dues: $err');
        isLoading.value = false;
      },
    );
  }

  /// Proactively resync and reconcile platform dues
  Future<void> refreshDues() async {
    try {
      isLoading.value = true;
      await DuesService.syncPendingDues();
    } catch (e) {
      debugPrint('[DuesController] Error syncing dues: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Triggers server-authoritative Razorpay Checkout flow to pay outstanding dues
  Future<void> payOutstanding() async {
    if (isPaying.value) return;

    try {
      await ConnectivityService.requireConnection();
    } catch (e) {
      ErrorHandler.handle(e);
      return;
    }

    if (outstanding.value <= 0) {
      AppSnackbar.info('You have no outstanding platform dues.', title: 'All Clear');
      return;
    }

    isPaying.value = true;

    try {
      // 1. Fetch user profile for contact and email prefill
      final profile = await DuesService.getUserProfile();
      final phone = (profile?['phoneNumber'] as String?) ?? '';
      final name = (profile?['name'] as String?) ?? 'Mechanic';
      final email = (profile?['email'] as String?) ?? '';

      // 2. Request Cloud Function to create Razorpay Order
      final orderData = await DuesService.createOrder();

      // 3. Open Razorpay Checkout modal
      await _checkoutService.openCheckout(
        orderData: orderData,
        mechanicPhone: phone,
        mechanicName: name,
        mechanicEmail: email,
        onSuccess: (result) async {
          isPaying.value = false;
          outstanding.value = 0.0;
          accountStatus.value = 'active';
          suspendedReason.value = null;

          AppSnackbar.success(
            'Payment verified! Your account is active.',
            title: 'Dues Cleared',
          );

          // Resync dues in background to keep ledger updated
          await DuesService.syncPendingDues();

          // If mechanic was on dedicated dues screen due to suspension, send to dashboard
          if (Get.currentRoute == Routes.MECHANIC_DUES) {
            Future.delayed(const Duration(milliseconds: 700), () {
              Get.offAllNamed(Routes.MECHANIC);
            });
          }
        },
        onFailure: (errorMessage, isCancelled) {
          isPaying.value = false;
          if (isCancelled) {
            AppSnackbar.info('Payment was cancelled.', title: 'Cancelled');
          } else {
            AppSnackbar.error(errorMessage, title: 'Payment Incomplete');
          }
        },
      );
    } catch (e) {
      isPaying.value = false;
      debugPrint('[DuesController] Error initiating dues payment: $e');
      final msg = e.toString();
      if (msg.contains('not-found') || msg.contains('UNAVAILABLE') || msg.contains('Functions')) {
        AppSnackbar.error(
          'Payment service is currently unavailable. Please check your connection or contact support.',
          title: 'Payments Unavailable',
        );
      } else {
        ErrorHandler.handle(e, fallbackMessage: 'Failed to initiate dues payment.');
      }
    }
  }

  @override
  void onClose() {
    _duesSub?.cancel();
    _userSub?.cancel();
    _checkoutService.dispose();
    super.onClose();
  }
}
