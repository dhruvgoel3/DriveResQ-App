import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/accept_request_indicator_card.dart';
import '../widgets/mechanic_active_job_card.dart';
import '../widgets/mechanic_empty_state.dart';
import '../../controller/mechanic_controller.dart';

class CurrentRequestView extends StatefulWidget {
  const CurrentRequestView({super.key});

  @override
  State<CurrentRequestView> createState() => _CurrentRequestViewState();
}

class _CurrentRequestViewState extends State<CurrentRequestView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<MechanicController>();
    _pageController = PageController(initialPage: controller.selectedTab.value);

    // Listen to tab changes and sync with PageView
    ever(controller.selectedTab, (index) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MechanicController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset("assets/—Pngtree—vector car repair tools illustration_5458319.png",height: 30,width: 30,),
            SizedBox(width: 10,),
            Text(
              "DriveResQ",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6C63FF),
              ),
            ),
          ],
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

          // 🔹 Tab Bar with Animation
          _animatedTabBar(controller),

          // 📋 Content Area with PageView for sliding
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => controller.changeInnerTab(index),
              children: [
                // Tab 0: ALL REQUESTS
                _buildAllRequestsTab(controller),

                // Tab 1: ACCEPTED REQUESTS
                _buildAcceptedRequestsTab(controller),
              ],
            ),
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

  // 🔹 Animated Tab Bar
  Widget _animatedTabBar(MechanicController controller) {
    return Obx(() {
      return Container(
        color: Colors.white,
        child: Row(
          children: [
            _tabButton("All Requests", 0, controller),
            _tabButton("Accepted Requests", 1, controller),
          ],
        ),
      );
    });
  }

  Widget _tabButton(String text, int index, MechanicController controller) {
    final isActive = controller.selectedTab.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeInnerTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
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

  // 📋 ALL REQUESTS TAB
  Widget _buildAllRequestsTab(MechanicController controller) {
    return Obx(() {
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

      // Filter only OPEN requests
      final openRequestsList = controller.openRequests
          .where((req) => req['status'] == 'open')
          .toList();

      // Check if there's an accepted job
      final hasAcceptedJob = controller.hasActiveJob.value;

      if (openRequestsList.isEmpty && !hasAcceptedJob) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
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

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Show indicator card ONLY HERE if there's an accepted job
          if (hasAcceptedJob) const AcceptedRequestIndicatorCard(),

          if (hasAcceptedJob) const SizedBox(height: 12),

          // Show message if no open requests but has accepted job
          if (openRequestsList.isEmpty && hasAcceptedJob)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 70,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No new requests",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You're currently working on an active request",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // List of open requests
          ...openRequestsList.map(
            (request) => MechanicActiveJobCard(
              job: request,
              isActive: false,
              onAccept: () => _showAcceptDialog(controller, request['id']),
            ),
          ),
        ],
      );
    });
  }

  // 📋 ACCEPTED REQUESTS TAB
  Widget _buildAcceptedRequestsTab(MechanicController controller) {
    return Obx(() {
      if (controller.hasActiveJob.value && controller.activeJob.value != null) {
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
    });
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
