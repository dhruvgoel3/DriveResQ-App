import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../driver/controllers/create_request_controller.dart';

class CreateRequestView extends StatelessWidget {
  CreateRequestView({super.key});

  final controller = Get.put(CreateRequestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Request")),
      body: Obx(() {
        return controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📍 Location
                    Text(
                      "Location",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(controller.locationName.value),

                    const SizedBox(height: 16),

                    // 📌 Landmark
                    TextField(
                      controller: controller.landmarkController,
                      decoration: const InputDecoration(
                        labelText: "Nearby Landmark *",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🚗 Vehicle Type
                    DropdownButtonFormField<String>(
                      items: ['Bike', 'Car', 'Truck']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (value) =>
                          controller.selectedVehicle.value = value!,
                      decoration: const InputDecoration(
                        labelText: "Vehicle Type *",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ❗ Problem
                    TextField(
                      controller: controller.problemController,
                      decoration: const InputDecoration(
                        labelText: "Problem *",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 📝 Description
                    TextField(
                      controller: controller.descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Description (Optional)",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 📷 Image
                    ElevatedButton.icon(
                      onPressed: controller.pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Add Image (Optional)"),
                    ),

                    const SizedBox(height: 24),

                    // 🚀 Submit
                    ElevatedButton(
                      onPressed: controller.submitRequest,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Submit Request"),
                    ),
                  ],
                ),
              );
      }),
    );
  }
}
