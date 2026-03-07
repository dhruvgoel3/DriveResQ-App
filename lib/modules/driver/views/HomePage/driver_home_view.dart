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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
        actions: [
          if (DevConfig.devMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.bug_report),
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
                const PopupMenuItem(
                  value: 'driver',
                  child: Text('Switch to Driver'),
                ),
                const PopupMenuItem(
                  value: 'mechanic',
                  child: Text('Switch to Mechanic'),
                ),
              ],
            ),

          Obx(() {
            if (!controller.hasActiveRequest.value) {
              return const SizedBox();
            }
            return IconButton(
              icon: const Icon(Icons.delete_outline),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔹 Active Request Card
                ActiveRequestCard(request: request),

                const SizedBox(height: 12),

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
