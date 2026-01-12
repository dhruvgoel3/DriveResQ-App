import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/accept_request_controller.dart';


class RequestDetailView extends StatelessWidget {
  final Map<String, dynamic> request;

  const RequestDetailView({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AcceptRequestController());

    return Scaffold(
      appBar: AppBar(title: const Text("Request Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info("Problem", request['problem']),
            _info("Vehicle", request['vehicleType']),
            _info("Location", request['locationName']),
            _info("Landmark", request['landmark']),
            if (request['description'] != null &&
                request['description'].toString().isNotEmpty)
              _info("Description", request['description']),

            const Spacer(),

            Obx(() {
              return ElevatedButton(
                onPressed: controller.isAccepting.value
                    ? null
                    : () {
                  controller.acceptRequest(request['id']);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: controller.isAccepting.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Accept Request"),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
