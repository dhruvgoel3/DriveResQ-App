import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/mechanic_active_job_card.dart';
import '../../controller/home_view_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MechanicDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Mechanic Dashboard"),
      ),
      body: Column(
        children: [
          _tabBar(controller),

          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 0) {
                return controller.hasActiveJob.value
                    ? MechanicActiveJobCard(job: controller.activeJob)
                    : const Center(child: Text("No active job"));
              } else {
                return const Center(child: Text("All Requests List"));
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabBar(MechanicDashboardController controller) {
    return Obx(() {
      return Row(
        children: [
          _tabButton("Current Job", 0, controller),
          _tabButton("All Requests", 1, controller),
        ],
      );
    });
  }

  Widget _tabButton(
    String text,
    int index,
    MechanicDashboardController controller,
  ) {
    final isActive = controller.selectedTab.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF6C63FF) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
