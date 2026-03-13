import 'package:driveresq_app/modules/driver/views/widgets/driver_empty_state.dart';
import 'package:driveresq_app/modules/driver/views/widgets/driver_safety_tips.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/routes/app_pages.dart';
import '../../../../shared/widgets/notification_bell_icon.dart';
import '../../../../utils/role_change/dev_config.dart';
import '../../../../utils/role_change/dev_role_container.dart';
import '../../controllers/driver_controller.dart';
import '../widgets/active_requests_card.dart';
import 'create_request_view.dart';

class DriverHomeView extends StatelessWidget {
  static const _accent = Color(0xFF6C63FF);

  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: Color(0xFFF7F7FC),
      body: SafeArea(
        child: Obx(() {
          if (controller.hasActiveRequest.value) {
            final request = controller.requestData.value!;

            return CustomScrollView(
              slivers: [
                // Premium App Bar
                SliverToBoxAdapter(child: _buildHeader(controller)),

                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ActiveRequestCard(request: request),
                      SizedBox(height: 12.h),
                      SafetyTipsSection(),
                    ]),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildHeader(controller),
              Expanded(
                child: DriverEmptyState(
                  onNewRequest: () => Get.to(() => CreateRequestView()),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(DriverController controller) {
    // Get the user's name from Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo + Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DriveResQ",
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: _accent,
                  ),
                ),
                SizedBox(height: 2.h),
                uid != null
                    ? StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String name = 'Driver';
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            name = data['fullName'] ??
                                data['name'] ??
                                'Driver';
                          }
                          return Text(
                            "Hello, $name 👋",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      )
                    : Text(
                        "Hello, Driver 👋",
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
              ],
            ),
          ),

          // Notification Bell
          const NotificationBellIcon(),

          // Dev mode switcher
          if (DevConfig.devMode)
            PopupMenuButton<String>(
              icon: Icon(Icons.bug_report, size: 22.w),
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
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: 'driver', child: Text('Switch to Driver')),
                PopupMenuItem(
                    value: 'mechanic', child: Text('Switch to Mechanic')),
              ],
            ),

          // Cancel request button
          Obx(() {
            if (!controller.hasActiveRequest.value) return SizedBox();
            return IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22.w),
              onPressed: () {
                Get.defaultDialog(
                  title: "Cancel Request",
                  middleText:
                      "Are you sure you want to cancel this request?",
                  textConfirm: "Yes",
                  textCancel: "No",
                  confirmTextColor: Colors.white,
                  onConfirm: () async {
                    Get.back();
                    await controller.cancelActiveRequest();
                  },
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
