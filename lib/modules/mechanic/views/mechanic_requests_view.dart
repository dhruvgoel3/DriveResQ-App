import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/widgets/active_job_card.dart';
import '../../../utils/widgets/mechanic_dashbaord_card.dart';
import '../controller/mechanic_request_controller.dart';

class MechanicRequestsView extends StatelessWidget {
  const MechanicRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MechanicRequestsController());

    return Scaffold(
      appBar: AppBar(title: const Text("Mechanic Dashboard")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 🔥 PRIORITY 1: ACTIVE REQUEST
        if (controller.activeRequest.value != null) {
          return ActiveJobCard(request: controller.activeRequest.value!);
        }

        // 🔥 PRIORITY 2: NEARBY REQUESTS
        if (controller.nearbyRequests.isEmpty) {
          return const Center(child: Text("No nearby requests right now"));
        }

        return ListView.builder(
          itemCount: controller.nearbyRequests.length,
          itemBuilder: (context, index) {
            return RequestCard(request: controller.nearbyRequests[index]);
          },
        );
      }),
    );
  }
}
