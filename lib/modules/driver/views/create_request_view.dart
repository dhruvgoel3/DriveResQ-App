import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Create Help Request",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📍 Location
              Text(
                "Location",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),

                onPressed: controller.pickImage,
                icon: Icon(Icons.camera_alt),
                label: Text(
                  "Add Image (Optional)",
                  style: GoogleFonts.poppins(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 210),

              // 🚀 Submit
              ElevatedButton(
                onPressed: controller.submitRequest,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: Color(0xFF6C63FF),
                  // Primary (modern blue-violet)
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Submit Request",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
