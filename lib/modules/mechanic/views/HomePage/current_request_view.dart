import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/mechanic_active_job_card.dart';
import '../widgets/mechanic_empty_state.dart';
import '../../controller/mechanic_controller.dart';

class CurrentRequestView extends StatelessWidget {
  const CurrentRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MechanicController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "DriveResQ Mechanic",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6C63FF),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshLocation(),
            tooltip: "Refresh Location",
          ),
        ],
      ),
      body: Column(
        children: [
          // 📍 Location Status Bar
          _locationStatusBar(controller),

          // 🔹 Tab Bar
          _tabBar(controller),

          // 📋 Content Area
          Expanded(
            child: Obx(() {
              // 🔹 CURRENT JOB TAB
              if (controller.selectedTab.value == 0) {
                if (controller.hasActiveJob.value &&
                    controller.activeJob.value != null) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: MechanicActiveJobCard(
                      job: controller.activeJob.value!,
                      isActive: true,
                      onCancel: () => _showCancelDialog(controller),
                    ),
                  );
                } else {
                  return const MechanicEmptyState();
                }
              }

              // 🔹 ALL REQUESTS TAB
              if (!controller.isLocationLoaded.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Loading location..."),
                    ],
                  ),
                );
              }

              if (controller.openRequests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No nearby requests",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Requests within 20 km will appear here",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.openRequests.length,
                itemBuilder: (context, index) {
                  final request = controller.openRequests[index];
                  return MechanicActiveJobCard(
                    job: request,
                    isActive: false,
                    onAccept: () => _showAcceptDialog(controller, request['id']),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // 📍 Location Status Bar
  Widget _locationStatusBar(MechanicController controller) {
    return Obx(() {
      if (!controller.isLocationLoaded.value) {
        return Container(
          color: Colors.orange.shade50,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                "Getting your location...",
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
        );
      }

      return Container(
        color: Colors.green.shade50,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Location active • Showing requests within 20 km",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.green.shade800,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 🔹 Tab Bar
  Widget _tabBar(MechanicController controller) {
    return Obx(() {
      return Container(
        color: Colors.white,
        child: Row(
          children: [
            _tabButton("Current Job", 0, controller),
            _tabButton("All Requests", 1, controller),
          ],
        ),
      );
    });
  }

  Widget _tabButton(
      String text,
      int index,
      MechanicController controller,
      ) {
    final isActive = controller.selectedTab.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeInnerTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF6C63FF) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 Show Accept Dialog
  void _showAcceptDialog(MechanicController controller, String requestId) {
    Get.defaultDialog(
      title: "Accept Request",
      middleText: "Do you want to accept this request?",
      textConfirm: "Accept",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF6C63FF),
      onConfirm: () {
        Get.back();
        controller.acceptRequest(requestId);
      },
    );
  }

  // ❌ Show Cancel Dialog
  void _showCancelDialog(MechanicController controller) {
    Get.defaultDialog(
      title: "Cancel Job",
      middleText: "Are you sure you want to cancel this job?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.cancelActiveJob();
      },
    );
  }
}