import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../shared/widgets/notification_bell_icon.dart';
import '../../controller/mechanic_controller.dart';
import '../widgets/accept_request_indicator_card.dart';
import '../widgets/mechanic_active_job_card.dart';
import '../widgets/mechanic_empty_state.dart';
import '../widgets/open_request_card.dart';

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
        leading: IconButton(
          icon: const Icon(Iconsax.menu_1, color: Color(0xFF212121)),
          onPressed: () => controller.scaffoldKey?.currentState?.openDrawer(),
        ),
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
                color: const Color(0xFF6C63FF),
              ),
            ),
          ],
        ),
        actions: [
          const NotificationBellIcon(),
          IconButton(
            icon: const Icon(Iconsax.refresh,color: Colors.black),
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
              Icon(Iconsax.location_slash, color: Colors.red, size: 16.w),
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
                child: const CircularProgressIndicator(strokeWidth: 2),
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
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.h,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              "Location active",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            Text(
              " • Requests within 20 km",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.green.shade600,
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
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF6C63FF) : Colors.transparent,
                width: 3.w,
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
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
      // Show a sleek progress indicator instead of the shimmer that causes flex issues
      if (!controller.isLocationLoaded.value &&
          controller.locationError.value == null) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
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
              Icon(
                Iconsax.search_normal,
                size: 80.w,
                color: Colors.grey.shade300,
              ),
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
                        Iconsax.archive,
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

            // Compact request cards
            ...openRequestsList.asMap().entries.map(
              (entry) => OpenRequestCard(
                job: entry.value,
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
        return const MechanicEmptyState();
      }
    });
  }

  // Accept Dialog — styled bottom sheet
  void _showAcceptDialog(MechanicController controller, String requestId) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.tick_circle, color: const Color(0xFF6C63FF), size: 40.w),
            ),
            SizedBox(height: 16.h),
            Text(
              "Accept This Request?",
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "You will be assigned to this driver and can start navigating to their location.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text("Cancel", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.acceptRequest(requestId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text("Accept", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Cancel Dialog — styled bottom sheet
  void _showCancelDialog(MechanicController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.close_circle, color: Colors.red, size: 40.w),
            ),
            SizedBox(height: 16.h),
            Text(
              "Cancel This Job?",
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "The driver will be notified and the request will go back to the open queue.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text("Keep Job", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.cancelActiveJob();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text("Yes, Cancel", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
