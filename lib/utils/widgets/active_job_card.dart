import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../modules/tracking/views/live_tracking_view.dart';
import '../helpers/call_helper.dart';

class ActiveJobCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const ActiveJobCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Active Request",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _row("Problem", request['problem']),
            _row("Vehicle", request['vehicleType']),
            _row("Location", request['locationName']),
            _row("Landmark", request['landmark']),
            _row("Driver Phone", request['driverPhone'] ?? "Not available"),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => LiveTrackingView(requestId: request['id']));

                      // Module 6: Navigate to map
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text("Navigate"),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    final phone = request['driverPhone'] ?? '';
                    CallHelper.callNumber(phone);
                  },
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text("$label: ${value?.toString() ?? 'N/A'}"),
    );
  }
}
