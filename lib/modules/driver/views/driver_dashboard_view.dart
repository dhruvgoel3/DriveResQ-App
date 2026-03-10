import 'package:driveresq_app/modules/driver/views/ProfilePage/driver_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/driver_controller.dart';
import '../../chat/views/chat_list_view.dart';
import 'HomePage/driver_home_view.dart';

class DriverDashboardView extends StatelessWidget {
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
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6C63FF),
          unselectedItemColor: Colors.grey.shade400,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Profile",
            ),
          ],
        ),
      );
    });
  }
}
