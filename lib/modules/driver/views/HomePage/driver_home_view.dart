import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes/app_pages.dart';
import '../../../../shared/widgets/notification_bell_icon.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/helpers/app_dialogs.dart';
import '../../../../utils/helpers/responsive_helper.dart';
import '../../../../utils/role_change/dev_config.dart';
import '../../../../utils/role_change/dev_role_container.dart';
import '../../controllers/driver_controller.dart';
import '../widgets/active_requests_card.dart';
import '../widgets/driver_dashboard_shimmer.dart';
import '../widgets/driver_safety_tips.dart';
import '../widgets/job_receipt_view.dart';
import 'create_request_view.dart';

/// Redesigned, ultra-modern Driver Home Screen.
/// Combines immediate emergency rescue action with intuitive service discovery,
/// live GPS coverage badges, and zero-clutter aesthetics.
class DriverHomeView extends StatelessWidget {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Modern Floating Header ──
            _buildCustomAppBar(context, controller),

            // ── Main Scrollable Canvas ──
            Expanded(
              child: Obx(() {
                if (controller.isLoadingRequest.value) {
                  return const DriverDashboardShimmer();
                }

                // If active request exists, prioritize tracking & status
                if (controller.hasActiveRequest.value) {
                  final request = controller.requestData.value!;
                  return _buildActiveRequestLayout(context, controller, request);
                }

                // Default state: Aesthetic emergency hero + service catalog
                return _buildDiscoveryDashboard(context, controller);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. APP BAR & LIVE LOCATION PILL
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCustomAppBar(BuildContext context, DriverController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.04), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Drawer hamburger button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.scaffoldKey?.currentState?.openDrawer(),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(Iconsax.menu_1, size: 20.w, color: AppColors.textPrimary),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Live location pill
          Expanded(
            child: GestureDetector(
              onTap: controller.fetchLocation,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Iconsax.location5, size: 14.w, color: AppColors.primary),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.currentLocationName.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Icon(Iconsax.arrow_down_1, size: 12.w, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // Notification bell
          const NotificationBellIcon(),

          // Dev mode role switcher
          if (DevConfig.devMode) ...[
            SizedBox(width: 4.w),
            PopupMenuButton<String>(
              icon: Icon(Iconsax.bag, size: 20.w, color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              onSelected: (value) {
                final devRole = Get.find<DevRoleController>();
                if (value == 'driver') {
                  devRole.switchToDriver();
                  Get.offAllNamed(Routes.DRIVER);
                } else if (value == 'mechanic') {
                  devRole.switchToMechanic();
                  Get.offAllNamed(Routes.MECHANIC);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'driver', child: Text('Switch to Driver')),
                PopupMenuItem(value: 'mechanic', child: Text('Switch to Mechanic')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. DISCOVERY DASHBOARD (DEFAULT NO-ACTIVE-REQUEST STATE)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildDiscoveryDashboard(BuildContext context, DriverController controller) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await controller.fetchLocation();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting & Avatar Row
            _buildGreetingRow(controller),
            SizedBox(height: 18.h),

            // Hero Emergency Breakdown Card
            _buildHeroRescueCard(context),
            SizedBox(height: 24.h),

            // Quick Roadside Services Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Instant Roadside Help",
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      "Pick an issue for prioritized dispatch",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => controller.changeTab(1),
                  child: Text(
                    "View Map",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 6-Card Services Grid
            _buildServicesGrid(),
            SizedBox(height: 16.h),

            // ResQ AI Safety Assistant Discovery Banner
            _buildResQAssistantBanner(),
            SizedBox(height: 20.h),

            // Interactive Live Radar Map Teaser Banner
            _buildRadarMapBanner(controller),
            SizedBox(height: 24.h),

            // Roadside Safety & Tips Accordion
            const SafetyTipsSection(),
            SizedBox(height: 20.h),

            // 24/7 Emergency SOS Helpline Bar
            _buildEmergencyHotlineCard(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. GREETING & PROFILE IDENTITY
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildGreetingRow(DriverController controller) {
    return Row(
      children: [
        // User profile avatar
        Obx(() {
          final photo = controller.driverPhotoUrl.value;
          final name = controller.driverName.value;
          final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';

          return Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: photo.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
          );
        }),
        SizedBox(width: 12.w),

        // Greeting Texts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  "Hello, ${controller.driverName.value} 👋",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Text(
                "Need roadside assistance? We're on standby.",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        // Active Shield Status Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.shield_tick5, size: 14.w, color: const Color(0xFF059669)),
              SizedBox(width: 4.w),
              Text(
                "Protected",
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. HERO EMERGENCY RESCUE CARD (HIGH-IMPACT AESTHETICS)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeroRescueCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1B4B), // Deep Midnight Indigo
            Color(0xFF2E2A72),
            Color(0xFF4338CA), // Electric Violet
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative ambient circles
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 40.w,
            bottom: -30.h,
            child: Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              ),
            ),
          ),

          // Main Card Content
          Padding(
            padding: EdgeInsets.all(22.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.flash5, size: 13.w, color: const Color(0xFFFBBF24)),
                          SizedBox(width: 5.w),
                          Text(
                            "RAPID DISPATCH",
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34D399),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Flexible(
                              child: Text(
                                "14 Active Mechanics Nearby",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6EE7B7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Headline
                Text(
                  "Vehicle Breakdown?\nGet Help in Minutes.",
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Certified mobile mechanics dispatched directly to your GPS coordinates with transparent upfront pricing.",
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: const Color(0xFFE0E7FF),
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 20.h),

                // Main CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => CreateRequestView()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E1B4B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4338CA),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Iconsax.add, color: Colors.white, size: 14.w),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Request Roadside Rescue",
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E1B4B),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(Iconsax.arrow_right_3, size: 16.w, color: const Color(0xFF1E1B4B)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. SERVICES GRID (6 QUICK-ACTION CATEGORIES)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildServicesGrid() {
    final services = [
      _ServiceItem(
        title: "Flat Tire",
        subtitle: "Puncture & Spare",
        icon: Iconsax.radar_2,
        color: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFF7ED),
        borderColor: const Color(0xFFFFEDD5),
      ),
      _ServiceItem(
        title: "Battery Dead",
        subtitle: "Jumpstart & Charge",
        icon: Iconsax.flash,
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFFFBEB),
        borderColor: const Color(0xFFFEF3C7),
      ),
      _ServiceItem(
        title: "Engine Trouble",
        subtitle: "Overheating & Fluids",
        icon: Iconsax.setting_2,
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFEE2E2),
      ),
      _ServiceItem(
        title: "Emergency Tow",
        subtitle: "Flatbed Towing",
        icon: Iconsax.truck_fast,
        color: const Color(0xFF4F46E5),
        bgColor: const Color(0xFFEEF2FF),
        borderColor: const Color(0xFFE0E7FF),
      ),
      _ServiceItem(
        title: "Fuel Delivery",
        subtitle: "Emergency Refuel",
        icon: Iconsax.drop,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        borderColor: const Color(0xFFEDE9FE),
      ),
      _ServiceItem(
        title: "Key Lockout",
        subtitle: "Door Lock Opening",
        icon: Iconsax.key,
        color: const Color(0xFF0284C7),
        bgColor: const Color(0xFFF0F9FF),
        borderColor: const Color(0xFFE0F2FE),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final item = services[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.to(() => CreateRequestView(initialProblem: item.title));
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: item.borderColor, width: 1.2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 20.w),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9.5.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5B. RESQ AI ASSISTANT DISCOVERY CARD
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildResQAssistantBanner() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.RESQ_ASSISTANT),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Iconsax.flash_15, color: Colors.white, size: 22),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "ResQ AI Assistant",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "AI",
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Unsure about vehicle symptoms? Get safe roadside guidance while waiting.",
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Iconsax.arrow_right_3, size: 16.w, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 6. RADAR MAP TEASER BANNER
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRadarMapBanner(DriverController controller) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Visual Map Radar Icon Stack
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Icon(Iconsax.map_1, color: AppColors.primary, size: 26.w),
            ),
          ),
          SizedBox(width: 14.w),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explore Mechanic Radar",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Browse ratings, reviews & distances on the live map",
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Arrow Button
          IconButton(
            onPressed: () => controller.changeTab(1),
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.arrow_right_3, size: 16.w, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 7. ACTIVE REQUEST HERO LAYOUT (WHEN DISPATCH IS IN PROGRESS)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildActiveRequestLayout(
    BuildContext context,
    DriverController controller,
    Map<String, dynamic> request,
  ) {
    final isCompleted = request['status'] == 'completed';
    final isVerifiedOrDone =
        request['status'] == 'verified' || request['status'] == 'completed';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Rescue Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    "EMERGENCY DISPATCH IN PROGRESS",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (!isVerifiedOrDone)
                  TextButton(
                    onPressed: () async {
                      final confirmed = await AppDialogs.confirm(
                        title: 'Cancel Request',
                        message: 'Are you sure you want to cancel this emergency request?',
                        confirmText: 'Cancel Request',
                        cancelText: 'Keep Request',
                        isDangerous: true,
                      );
                      if (confirmed == true) {
                        await controller.cancelActiveRequest();
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Primary Card (Receipt or Active Request Tracking Card)
          if (isCompleted)
            JobReceiptView(request: request)
          else
            ActiveRequestCard(request: request),

          SizedBox(height: 16.h),
          const SafetyTipsSection(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 8. EMERGENCY SOS HELPLINE BAR
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildEmergencyHotlineCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: const BoxDecoration(
              color: Color(0xFFFCA5A5),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.call5, color: const Color(0xFF991B1B), size: 18.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "National Highway Helpline: 1033",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF991B1B),
                  ),
                ),
                Text(
                  "Toll-free emergency roadside assistance",
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse('tel:1033');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(
              "Call SOS",
              style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper model for the 6-service grid
class _ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  _ServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });
}
