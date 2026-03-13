import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/widgets/TextFields/app_input_decoration.dart';
import '../../../../utils/widgets/TextFields/app_text_fields.dart';
import '../../controllers/create_request_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Create Help Request",
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
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
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📍 Location
              Text(
                "Location",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(controller.locationName.value),

              SizedBox(height: 20.h),

              // 📌 Landmark
              AppTextField(
                controller: controller.landmarkController,
                label: "Nearby Landmark",
                icon: Icons.location_on,
                isRequired: true,
              ),

              SizedBox(height: 16.h),

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

              SizedBox(height: 16.h),

              // ❗ Problem
              AppTextField(
                controller: controller.problemController,
                label: "Problem",
                icon: Icons.report_problem,
                isRequired: true,
              ),

              SizedBox(height: 16.h),

              // 📝 Description
              AppTextField(
                controller: controller.descriptionController,
                label: "Description (Optional)",
                icon: Icons.notes,
                maxLines: 3,
              ),

              SizedBox(height: 16.h),

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
                    fontSize: 14.sp,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // 🚀 Submit
              ElevatedButton(
                onPressed: controller.submitRequest,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 52),
                  backgroundColor: Color(0xFF6C63FF),
                  // Primary (modern blue-violet)
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  "Submit Request",
                  style: TextStyle(
                    fontSize: 16.sp,
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
