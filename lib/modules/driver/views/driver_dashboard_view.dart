import 'package:driveresq_app/modules/driver/views/ProfilePage/driver_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import '../controllers/driver_controller.dart';
import '../../chat/views/chat_list_view.dart';
import 'HomePage/driver_home_view.dart';

class DriverDashboardView extends StatelessWidget {
  static const _accent = Color(0xFF6C63FF);

  const DriverDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [DriverHomeView(), ChatListView(), DriverProfileView()],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: _accent,
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(),
            elevation: 0,
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Icon(Icons.home_rounded, size: 24.w),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Icon(Icons.home_rounded, size: 26.w),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Icon(Icons.chat_bubble_rounded, size: 22.w),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Icon(Icons.chat_bubble_rounded, size: 24.w),
                ),
                label: "Chats",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Icon(Icons.person_rounded, size: 24.w),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Icon(Icons.person_rounded, size: 26.w),
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      );
    });
  }
}
