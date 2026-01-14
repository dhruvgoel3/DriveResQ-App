import 'package:driveresq_app/modules/driver/views/driver_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/driver_controller.dart';
import 'driver_home_view.dart';

class DriverDashboardView extends StatelessWidget {
  const DriverDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            DriverHomeView(),
            DriverProfileView(),

            Center(child: Text("Profile (Later)")),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6C63FF),
          unselectedItemColor: Colors.black,
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      );
    });
  }
}
