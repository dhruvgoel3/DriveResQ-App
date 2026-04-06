import 'package:driveresq_app/modules/mechanic/views/ProfilePage/mechanic_profile_view.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';

import '../../chat/views/chat_list_view.dart';
import '../../../shared/widgets/exit_guard.dart';
import '../controller/mechanic_controller.dart';
import 'History/mechanic_history_view.dart';
import 'HomePage/current_request_view.dart';

class MechanicDashboardView extends StatelessWidget {
  MechanicDashboardView({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MechanicController>();
    // Store the scaffold key so child views can access it
    controller.scaffoldKey = _scaffoldKey;

    // Pre-build tab pages once
    final pages = [
      const CurrentRequestView(),
      const MechanicHistoryView(),
      const ChatListView(),
      const MechanicProfileView(),
    ];

    return Obx(
      () => ExitGuard(
        currentTab: () => controller.currentIndex.value,
        onSwitchToHome: () => controller.changeTab(0),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          body: IndexedStack(index: controller.currentIndex.value, children: pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                child: GNav(
                  rippleColor: AppColors.primary.withOpacity(0.2),
                  hoverColor: AppColors.primary.withOpacity(0.1),
                  gap: 8,
                  activeColor: AppColors.primary,
                  iconSize: 24,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: AppColors.primary.withOpacity(0.1),
                  color: AppColors.textHint,
                  textStyle: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  selectedIndex: controller.currentIndex.value,
                  onTabChange: controller.changeTab,
                  tabs: const [
                    GButton(icon: Iconsax.home, text: 'Home'),
                    GButton(icon: Iconsax.clock, text: 'History'),
                    GButton(icon: Iconsax.message, text: 'Chats'),
                    GButton(icon: Iconsax.profile_circle, text: 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
