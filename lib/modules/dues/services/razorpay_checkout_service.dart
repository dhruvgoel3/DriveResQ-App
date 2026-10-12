import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:driveresq_app/modules/dues/services/dues_service.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';

typedef OnPaymentVerificationSuccess = void Function(Map<String, dynamic> result);
typedef OnPaymentVerificationFailure = void Function(String error);

/// Service wrapping Razorpay Flutter Checkout.
/// NEVER trusts checkout success alone: always verifies HMAC SHA-256 signature
/// with Cloud Functions before declaring the payment settled.
class RazorpayCheckoutService {
  late final Razorpay _razorpay;
  OnPaymentVerificationSuccess? _onSuccess;
  OnPaymentVerificationFailure? _onFailure;
  String? _currentOrderId;

  RazorpayCheckoutService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  /// Initiates Razorpay checkout flow with credentials from Cloud Functions order response
  /// and local dotenv fallback.
  Future<void> openCheckout({
    required Map<String, dynamic> orderData,
    required String mechanicPhone,
    required String mechanicName,
    required OnPaymentVerificationSuccess onSuccess,
    required OnPaymentVerificationFailure onFailure,
  }) async {
    _onSuccess = onSuccess;
    _onFailure = onFailure;

    final orderId = orderData['orderId'] as String?;
    final amountPaise = orderData['amount'];
    final serverKeyId = orderData['keyId'] as String?;
    final envKeyId = dotenv.env['RAZORPAY_KEY_ID']?.trim();

    final keyId = (serverKeyId != null && serverKeyId.isNotEmpty)
        ? serverKeyId
        : (envKeyId ?? '');

    if (keyId.isEmpty || keyId.startsWith('rzp_test_xxxx')) {
      onFailure(
        'Razorpay Key ID is not configured. Please set RAZORPAY_KEY_ID in .env or Cloud Functions.',
      );
      return;
    }

    if (orderId == null || orderId.isEmpty) {
      onFailure('Invalid order received from server.');
      return;
    }

    _currentOrderId = orderId;

    final options = {
      'key': keyId,
      'amount': amountPaise,
      'name': 'DriveResQ',
      'order_id': orderId,
      'description': 'Platform Dues Settlement',
      'currency': orderData['currency'] ?? 'INR',
      'timeout': 300, // 5 minutes
      'prefill': {
        'contact': mechanicPhone,
        'name': mechanicName,
      },
      'theme': {
        'color': '#FF9800', // DriveResQ Mechanic Warm Accent
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('[RazorpayCheckoutService] Error launching checkout: $e');
      onFailure('Could not open payment gateway: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final orderId = response.orderId ?? _currentOrderId ?? '';
    final paymentId = response.paymentId ?? '';
    final signature = response.signature ?? '';

    if (paymentId.isEmpty || signature.isEmpty) {
      _onFailure?.call('Incomplete payment response from gateway.');
      return;
    }

    try {
      // Cryptographic verification via server callable
      final verifyResult = await DuesService.verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );

      if (verifyResult['success'] == true) {
        _onSuccess?.call(verifyResult);
      } else {
        _onFailure?.call(
          verifyResult['message'] as String? ?? 'Payment verification failed.',
        );
      }
    } catch (e) {
      debugPrint('[RazorpayCheckoutService] Payment verification failed: $e');
      _onFailure?.call(
        'Payment was received by gateway but server verification failed: $e',
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
      '[RazorpayCheckoutService] Payment error: code=${response.code}, message=${response.message}',
    );
    final errorMsg = response.message ?? 'Payment was cancelled or unsuccessful.';
    AppSnackbar.error(errorMsg, title: 'Payment Failed');
    _onFailure?.call(errorMsg);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint(
      '[RazorpayCheckoutService] External wallet chosen: ${response.walletName}',
    );
  }
}
