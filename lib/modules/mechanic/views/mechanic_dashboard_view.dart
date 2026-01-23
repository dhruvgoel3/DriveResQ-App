import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/mechanic_controller.dart';
import 'HomePage/home_view.dart';

class MechanicDashboardView extends StatelessWidget {
  const MechanicDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MechanicController>();

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeView(), // 🔥 Combined Home
            Center(child: Text("Profile (Later)")),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
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
/// thakurrr