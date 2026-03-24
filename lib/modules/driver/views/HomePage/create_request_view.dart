import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/create_request_controller.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Create Help Request",
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16.h),
                Text(
                  "Submitting your request...",
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
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
              // ── LOCATION CARD ──
              _sectionLabel("Your Location", Iconsax.gps),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: controller.editLocationName,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      _iconBox(Iconsax.gps),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Location (Tap to edit)",
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Obx(
                              () => Text(
                                controller.locationName.value.isEmpty
                                    ? "Fetching location..."
                                    : controller.locationName.value,
                                style: AppTextStyles.body2.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: controller.locationName.value ==
                                          "Enable location to continue"
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Iconsax.edit_2, color: AppColors.primary, size: 20.w),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // ── LANDMARK ──
              _sectionLabel("Nearby Landmark", Iconsax.location),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.landmarkController,
                hint: "e.g. Near SBI Bank, Main Road",
                icon: Iconsax.location,
              ),

              SizedBox(height: 20.h),

              // ── VEHICLE TYPE ──
              _sectionLabel("Vehicle Type", Iconsax.car),
              SizedBox(height: 8.h),
              Container(
                decoration: _cardDecoration(),
                child: DropdownButtonFormField<String>(
                  value: controller.selectedVehicle.value.isEmpty
                      ? null
                      : controller.selectedVehicle.value,
                  hint: Text(
                    "Select your vehicle type",
                    style: AppTextStyles.body2.copyWith(color: AppColors.textHint),
                  ),
                  items: vehicleTypes
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    controller.selectedVehicle.value = value!;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 12.w, right: 8.w),
                      child: Icon(Iconsax.car, color: AppColors.primary, size: 22.w),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 42.w, minHeight: 42.h),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  ),
                  dropdownColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),

              SizedBox(height: 20.h),

              // ── VEHICLE NUMBER PLATE ──
              _sectionLabel("Vehicle Number", Iconsax.hashtag),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.vehicleNumberController,
                hint: "e.g. DL 01 AB 1234",
                icon: Iconsax.hashtag,
                textCapitalization: TextCapitalization.characters,
              ),

              SizedBox(height: 20.h),

              // ── PROBLEM ──
              _sectionLabel("What's the problem?", Iconsax.warning_2),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.problemController,
                hint: "e.g. Flat tyre, Engine won't start, Battery dead",
                icon: Iconsax.warning_2,
              ),

              SizedBox(height: 20.h),

              // ── DESCRIPTION ──
              _sectionLabel("Additional Details (Optional)", Iconsax.document_text),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.descriptionController,
                hint: "Any extra info for the mechanic...",
                icon: Iconsax.document_text,
                maxLines: 3,
              ),

              SizedBox(height: 20.h),

              // ── IMAGE ──
              _sectionLabel("Add Photo (Optional)", Iconsax.camera),
              SizedBox(height: 8.h),
              Obx(
                () => GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 80.h,
                    decoration: _cardDecoration().copyWith(
                      border: Border.all(
                        color: controller.imageFile.value != null
                            ? AppColors.success.withOpacity(0.4)
                            : AppColors.border,
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
                              ? AppColors.success
                              : AppColors.textHint,
                          size: 26.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          controller.imageFile.value != null
                              ? "Photo selected (tap to change)"
                              : "Tap to take a photo",
                          style: AppTextStyles.body2.copyWith(
                            color: controller.imageFile.value != null
                                ? AppColors.primary
                                : AppColors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // ── SUBMIT ──
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: controller.submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.send_1, size: 20.w),
                      SizedBox(width: 8.w),
                      Text(
                        "Submit Request",
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
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

  // ─── Section Label with Icon ───
  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: AppColors.primary),
        SizedBox(width: 6.w),
        Text(
          text,
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Card Decoration ───
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ─── Icon Box ───
  Widget _iconBox(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: AppColors.primary, size: 22.w),
    );
  }

  // ─── Styled TextField ───
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: _cardDecoration(),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textHint),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 12.w, right: 8.w, top: maxLines > 1 ? 14.h : 0),
            child: Icon(icon, color: AppColors.primary, size: 22.w),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 42.w, minHeight: 42.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
