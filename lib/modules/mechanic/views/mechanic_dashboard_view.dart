import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/mechanic_controller.dart';
import 'mechanic_requests_view.dart';
import 'mechanic_active_job_view.dart';

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
            MechanicRequestsView(),
            MechanicActiveJobView(),
            Center(child: Text("Profile (Later)")),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "Requests"),
            BottomNavigationBarItem(icon: Icon(Icons.build), label: "Active"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      );
    });
  }
}
