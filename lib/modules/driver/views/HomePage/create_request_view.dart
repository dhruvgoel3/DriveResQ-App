import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/create_request_controller.dart';

class CreateRequestView extends StatelessWidget {
  CreateRequestView({super.key});

  static const _accent = Color(0xFF6C63FF);

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
      backgroundColor: Color(0xFFF7F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Create Help Request",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: _accent),
                SizedBox(height: 16.h),
                Text(
                  "Submitting your request...",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ━━━ LOCATION CARD ━━━
              _sectionLabel("📍 Your Location"),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: controller.editLocationName,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Iconsax.gps,
                          color: _accent,
                          size: 22.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Location (Tap to edit)",
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: _accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Obx(
                              () => Text(
                                controller.locationName.value.isEmpty
                                    ? "Fetching location..."
                                    : controller.locationName.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      controller.locationName.value ==
                                          "Enable location to continue"
                                      ? Colors.red.shade400
                                      : Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Iconsax.edit_2, color: _accent, size: 20.w),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // ━━━ LANDMARK ━━━
              _sectionLabel("📌 Nearby Landmark"),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.landmarkController,
                hint: "e.g. Near SBI Bank, Main Road",
                icon: Iconsax.location,
              ),

              SizedBox(height: 20.h),

              // ━━━ VEHICLE TYPE ━━━
              _sectionLabel("🚗 Vehicle Type"),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonFormField<String>(
                  value: controller.selectedVehicle.value.isEmpty
                      ? null
                      : controller.selectedVehicle.value,
                  hint: Text(
                    "Select your vehicle type",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  items: vehicleTypes
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    controller.selectedVehicle.value = value!;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Iconsax.car,
                      color: _accent,
                      size: 22.w,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),

              SizedBox(height: 20.h),

              // ━━━ PROBLEM ━━━
              _sectionLabel("❗ What's the problem?"),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.problemController,
                hint: "e.g. Flat tyre, Engine won't start, Battery dead",
                icon: Iconsax.warning_2,
              ),

              SizedBox(height: 20.h),

              // ━━━ DESCRIPTION ━━━
              _sectionLabel("📝 Additional Details (Optional)"),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.descriptionController,
                hint: "Any extra info for the mechanic...",
                icon: Iconsax.document_text,
                maxLines: 3,
              ),

              SizedBox(height: 20.h),

              // ━━━ IMAGE ━━━
              _sectionLabel("📷 Add Photo (Optional)"),
              SizedBox(height: 8.h),
              Obx(
                () => GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: controller.imageFile.value != null
                            ? _accent.withOpacity(0.4)
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          controller.imageFile.value != null
                              ? Iconsax.tick_circle
                              : Iconsax.camera,
                          color: controller.imageFile.value != null
                              ? Colors.green
                              : Colors.grey.shade400,
                          size: 26.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          controller.imageFile.value != null
                              ? "Photo selected ✓  (tap to change)"
                              : "Tap to take a photo",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: controller.imageFile.value != null
                                ? _accent
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // ━━━ SUBMIT ━━━
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: controller.submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: _accent.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.send, size: 20.w),
                      SizedBox(width: 8.w),
                      Text(
                        "Submit Request",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  // ─── Section Label ───
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // ─── Styled TextField ───
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: Colors.grey.shade400,
          ),
          prefixIcon: Icon(icon, color: _accent, size: 22.w),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }
}
