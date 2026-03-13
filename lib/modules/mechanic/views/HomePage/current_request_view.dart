import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/notification_bell_icon.dart';
import '../widgets/accept_request_indicator_card.dart';
import '../widgets/mechanic_active_job_card.dart';
import '../widgets/mechanic_empty_state.dart';
import '../widgets/request_card_shimmer.dart';
import '../../controller/mechanic_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

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
          duration: Duration(milliseconds: 300),
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
      backgroundColor: Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              "assets/—Pngtree—vector car repair tools illustration_5458319.png",
              height: 30.h,
              width: 30.w,
            ),
            SizedBox(width: 10.w),
            Text(
              "DriveResQ",
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
          ],
        ),
        actions: [
          const NotificationBellIcon(),
          IconButton(
            icon: Icon(Icons.refresh),
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

  // Location Status Bar
  Widget _locationStatusBar(MechanicController controller) {
    return Obx(() {
      // Error state — show error with retry
      if (controller.locationError.value != null) {
        return Container(
          color: Colors.red.shade50,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          child: Row(
            children: [
              Icon(Icons.location_off, color: Colors.red, size: 16.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  controller.locationError.value!,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.refreshLocation(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "Retry",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Loading state
      if (!controller.isLocationLoaded.value) {
        return Container(
          color: Colors.orange.shade50,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          child: Row(
            children: [
              SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12.w),
              Text(
                "Getting your location...",
                style: GoogleFonts.poppins(fontSize: 13.sp),
              ),
            ],
          ),
        );
      }

      // Success state
      return Container(
        color: Colors.green.shade50,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green, size: 16.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                "Location active • Showing requests within 20 km",
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
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
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Color(0xFF6C63FF) : Colors.transparent,
                width: 3.w,
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: isActive ? Color(0xFF6C63FF) : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ALL REQUESTS TAB
  Widget _buildAllRequestsTab(MechanicController controller) {
    return Obx(() {
      // Show shimmer while location is loading (and no error)
      if (!controller.isLocationLoaded.value &&
          controller.locationError.value == null) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: const RequestCardShimmer(count: 3),
        );
      }

      final openRequestsList = controller.openRequests
          .where((req) => req['status'] == 'open')
          .toList();

      final hasAcceptedJob = controller.hasActiveJob.value;

      if (openRequestsList.isEmpty && !hasAcceptedJob) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80.w, color: Colors.grey.shade300),
              SizedBox(height: 16.h),
              Text(
                "No nearby requests",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                controller.locationError.value != null
                    ? "Enable location to discover requests"
                    : "Requests within 20 km will appear here",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshLocation(),
        color: const Color(0xFF6C63FF),
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            if (hasAcceptedJob) AcceptedRequestIndicatorCard(),
            if (hasAcceptedJob) SizedBox(height: 12.h),

            if (openRequestsList.isEmpty && hasAcceptedJob)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 70.w,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No new requests",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "You're currently working on an active request",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // List with stagger animation index
            ...openRequestsList.asMap().entries.map(
              (entry) => MechanicActiveJobCard(
                job: entry.value,
                isActive: false,
                animationIndex: entry.key,
                onAccept: () =>
                    _showAcceptDialog(controller, entry.value['id']),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 📋 ACCEPTED REQUESTS TAB
  Widget _buildAcceptedRequestsTab(MechanicController controller) {
    return Obx(() {
      if (controller.hasActiveJob.value && controller.activeJob.value != null) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: MechanicActiveJobCard(
            job: controller.activeJob.value!,
            isActive: true,
            onCancel: () => _showCancelDialog(controller),
          ),
        );
      } else {
        return MechanicEmptyState();
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
      buttonColor: Color(0xFF6C63FF),
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
