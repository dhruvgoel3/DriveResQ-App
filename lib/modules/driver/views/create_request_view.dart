import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/widgets/TextFields/app_input_decoration.dart';
import '../../../utils/widgets/TextFields/app_text_fields.dart';
import '../controllers/create_request_controller.dart';

class CreateRequestView extends StatelessWidget {
  CreateRequestView({super.key});

  final controller = Get.put(CreateRequestController());

  final List<String> vehicleTypes = [
    'Bike',
    'Scooter',
    'Car',
    'SUV',
    'Van',
    'Truck',
    'Auto Rickshaw',
    'Bus',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Request")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📍 Location
              const Text(
                "Location",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(controller.locationName.value),

              const SizedBox(height: 20),

              // 📌 Landmark
              AppTextField(
                controller: controller.landmarkController,
                label: "Nearby Landmark",
                icon: Icons.location_on,
                isRequired: true,
              ),

              const SizedBox(height: 16),

              // 🚗 Vehicle Type
              DropdownButtonFormField<String>(
                value: controller.selectedVehicle.value.isEmpty
                    ? null
                    : controller.selectedVehicle.value,
                items: vehicleTypes
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  controller.selectedVehicle.value = value!;
                },
                decoration: AppInputDecoration(
                  label: "Vehicle Type *",
                  icon: Icons.directions_car,
                ),
              ),

              const SizedBox(height: 16),

              // ❗ Problem
              AppTextField(
                controller: controller.problemController,
                label: "Problem",
                icon: Icons.report_problem,
                isRequired: true,
              ),

              const SizedBox(height: 16),

              // 📝 Description
              AppTextField(
                controller: controller.descriptionController,
                label: "Description (Optional)",
                icon: Icons.notes,
                maxLines: 3,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
