import 'package:driveresq_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

import '../../controllers/driver_profile_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/profile_personal_info.dart';
import 'widgets/profile_identity_card.dart';
import 'widgets/profile_logout_button.dart';

class DriverProfileView extends StatelessWidget {
  const DriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DriverProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (c.userData.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return CustomScrollView(
          slivers: [
            ProfileHeader(controller: c),
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ProfileStats(controller: c),
                  SizedBox(height: 16.h),
                  ProfilePersonalInfo(controller: c),
                  SizedBox(height: 16.h),
                  ProfileIdentityCard(controller: c),
                  SizedBox(height: 24.h),
                  ProfileLogoutButton(controller: c),
                  SizedBox(height: 24.h),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }
}
