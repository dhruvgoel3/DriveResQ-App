import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/mechanic_active_job_card.dart';
import '../../controller/current_request_controller.dart';

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
              // 🔹 CURRENT JOB TAB
              if (controller.selectedTab.value == 0) {
                if (controller.hasActiveJob.value &&
                    controller.activeJob.value != null) {
                  return MechanicActiveJobCard(
                    job: controller.activeJob.value!,
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No active job",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
              }

              // 🔹 ALL REQUESTS TAB
              if (controller.openRequests.isEmpty) {
                return const Center(
                  child: Text(
                    "No nearby requests",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.openRequests.length,
                itemBuilder: (context, index) {
                  final request = controller.openRequests[index];
                  return MechanicActiveJobCard(job: request);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // 🔹 TAB BAR
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
