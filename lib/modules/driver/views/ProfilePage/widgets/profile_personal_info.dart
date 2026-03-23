import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import '../../../controllers/driver_profile_controller.dart';
import 'profile_card_container.dart';

class ProfilePersonalInfo extends StatelessWidget {
  final DriverProfileController controller;
  const ProfilePersonalInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProfileCardContainer(
      title: 'PERSONAL INFORMATION',
      icon: Icons.person,
      child: Obx(() {
        final edit = controller.isEditMode.value;
        return Column(
          children: [
            if (edit) ...[
              _editField('Full Name', controller.nameController, Icons.person),
              SizedBox(height: 12.h),
              _editField('Email', controller.emailController, Icons.email),
              SizedBox(height: 12.h),
              _editField(
                'Address',
                controller.addressController,
                Icons.home,
                maxLines: 2,
              ),
              SizedBox(height: 12.h),
              _editField('Gender', controller.genderController, Icons.wc),
              SizedBox(height: 12.h),
              _editField('Date of Birth (YYYY-MM-DD)', controller.dobController, Icons.cake),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.saveBasicInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              color: AppColors.surface,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: AppTextStyles.button.copyWith(color: AppColors.surface),
                          ),
                  ),
                ),
              ),
            ] else ...[
              _infoRow(Icons.person, 'Full Name', controller.displayName),
              _sep(),
              _infoRow(Icons.phone, 'Phone', controller.phone.isNotEmpty ? controller.phone : 'Not added'),
              _sep(),
              _infoRow(Icons.email, 'Email', controller.email.isNotEmpty ? controller.email : 'Not added'),
              _sep(),
              _infoRow(Icons.home, 'Address', controller.address.isNotEmpty ? controller.address : 'Not added'),
              _sep(),
              _infoRow(Icons.wc, 'Gender', controller.gender.isNotEmpty ? controller.gender : 'Not added'),
              _sep(),
              _infoRow(Icons.cake, 'Date of Birth', controller.dob.isNotEmpty ? controller.dob : 'Not added'),
            ],
          ],
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.w, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(fontSize: 11.sp),
                ),
                Text(
                  value,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w500,
                    color: value == 'Not added' ? AppColors.textHint : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sep() => Divider(height: 16.h, thickness: 0.5, color: AppColors.border.withOpacity(0.5));

  Widget _editField(
    String label,
    TextEditingController textController,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: textController,
      maxLines: maxLines,
      style: AppTextStyles.body2,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, size: 20.w, color: AppColors.primary),
        filled: false,
        fillColor: AppColors.background,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
