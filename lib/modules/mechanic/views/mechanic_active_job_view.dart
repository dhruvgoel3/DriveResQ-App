import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/mechanic_active_job_controller.dart';

class MechanicActiveJobView extends StatelessWidget {
  const MechanicActiveJobView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MechanicActiveJobController());

    return Obx(() {
      if (controller.activeJob.value == null) {
        return const Center(child: Text("No active job"));
      }

      final job = controller.activeJob.value!;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: ListTile(
            title: Text(job['problem']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job['locationName']),
                Text("Driver: ${job['driverPhone']}"), // 📞
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () {
                // Module 6: Call driver
              },
            ),
          ),
        ),
      );
    });
  }
}
