import 'package:driveresq_app/modules/driver/views/widgets/driver_empty_state.dart';
import 'package:driveresq_app/modules/driver/views/widgets/driver_safety_tips.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_pages.dart';
import '../../../../utils/role_change/dev_config.dart';
import '../../../../utils/role_change/dev_role_container.dart';
// ✅ CORRECT
import '../../controllers/driver_controller.dart';
import '../widgets/active_requests_card.dart';
import 'create_request_view.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class DriverHomeView extends StatelessWidget {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "DriveResQ",
          style: GoogleFonts.poppins(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
        actions: [
          if (DevConfig.devMode)
            PopupMenuButton<String>(
              icon: Icon(Icons.bug_report),
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
                PopupMenuItem(value: 'driver', child: Text('Switch to Driver')),
                PopupMenuItem(
                  value: 'mechanic',
                  child: Text('Switch to Mechanic'),
                ),
              ],
            ),

          Obx(() {
            if (!controller.hasActiveRequest.value) {
              return SizedBox();
            }
            return IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () {
                Get.defaultDialog(
                  title: "Cancel Request",
                  middleText: "Are you sure you want to cancel this request?",
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
      body: Obx(() {
        if (controller.hasActiveRequest.value) {
          final request = controller.requestData.value!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // 🔹 Active Request Card
                ActiveRequestCard(request: request),

                SizedBox(height: 12.h),

                SafetyTipsSection(),
              ],
            ),
          );
        }

        return DriverEmptyState(
          onNewRequest: () {
            Get.to(() => CreateRequestView());
          },
        );
      }),
    );
  }
}
