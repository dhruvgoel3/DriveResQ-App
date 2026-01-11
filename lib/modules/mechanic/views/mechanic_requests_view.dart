import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/widgets/mechanic_dashbaord_card.dart';
import '../controller/mechanic_request_controller.dart';


class MechanicRequestsView extends StatelessWidget {
  const MechanicRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MechanicRequestsController());

    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Requests")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
            ),
          );
        }

        if (controller.nearbyRequests.isEmpty) {
          return const Center(
            child: Text("No nearby requests right now"),
          );
        }

        return ListView.builder(
          itemCount: controller.nearbyRequests.length,
          itemBuilder: (context, index) {
            return RequestCard(
              request: controller.nearbyRequests[index],
            );
          },
        );
      }),
    );
  }
}
