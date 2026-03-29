import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/modules/driver/views/widgets/driver_dashboard_shimmer.dart';
import 'package:driveresq_app/modules/driver/views/widgets/driver_empty_state.dart';
import 'package:driveresq_app/modules/driver/views/widgets/driver_safety_tips.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/utils/helpers/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/routes/app_pages.dart';
import '../../../../shared/widgets/notification_bell_icon.dart';
import '../../../../utils/role_change/dev_config.dart';
import '../../../../utils/role_change/dev_role_container.dart';
import '../../controllers/driver_controller.dart';
import '../widgets/active_requests_card.dart';
import '../widgets/job_receipt_view.dart';
import 'create_request_view.dart';

class DriverHomeView extends StatelessWidget {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Iconsax.menu_1, color: AppColors.textPrimary),
          onPressed: () => controller.scaffoldKey?.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DriveResQ",
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (uid != null)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String name = 'Driver';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    name = data['fullName'] ?? data['name'] ?? 'Driver';
                  }
                  return Text("Hello, $name 👋", style: AppTextStyles.caption);
                },
              ),
          ],
        ),
        actions: [
          const NotificationBellIcon(),
          if (DevConfig.devMode)
            PopupMenuButton<String>(
              icon: Icon(Iconsax.bag, size: 22.w),
              onSelected: (value) {
                final devRole = Get.find<DevRoleController>();
                if (value == 'driver') {
                  devRole.switchToDriver();
                  Get.offAllNamed(Routes.DRIVER);
                } else if (value == 'mechanic') {
                  devRole.switchToMechanic();
                  Get.offAllNamed(Routes.MECHANIC);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'driver', child: Text('Switch to Driver')),
                PopupMenuItem(
                  value: 'mechanic',
                  child: Text('Switch to Mechanic'),
                ),
              ],
            ),
          Obx(() {
            if (controller.isLoadingRequest.value ||
                !controller.hasActiveRequest.value) {
              return const SizedBox();
            }
            final req = controller.requestData.value!;
            if (req['status'] == 'verified' || req['status'] == 'completed') {
              return const SizedBox();
            }

            return IconButton(
              icon: Icon(Iconsax.trash, color: AppColors.error, size: 22.w),
              onPressed: () async {
                final confirmed = await AppDialogs.confirm(
                  title: 'Cancel Request',
                  message: 'Are you sure you want to cancel this request?',
                  confirmText: 'Yes',
                  cancelText: 'No',
                  isDangerous: true,
                );
                if (confirmed == true) {
                  await controller.cancelActiveRequest();
                }
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingRequest.value) {
          return const DriverDashboardShimmer();
        }

        if (controller.hasActiveRequest.value) {
          final request = controller.requestData.value!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                if (request['status'] == 'completed')
                  JobReceiptView(request: request)
                else
                  ActiveRequestCard(request: request),
                SizedBox(height: 12.h),
                const SafetyTipsSection(),
              ],
            ),
          );
        }

        return DriverEmptyState(
          onNewRequest: () => Get.to(() => CreateRequestView()),
        );
      }),
    );
  }
}
