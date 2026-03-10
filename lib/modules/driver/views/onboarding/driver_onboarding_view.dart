import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/driver_onboarding_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class DriverOnboardingView extends StatelessWidget {
  static const _accent = Color(0xFF6C63FF);

  const DriverOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DriverOnboardingController());

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Setup Your Profile',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: Obx(
          () => c.currentStep.value > 0
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: c.previousStep,
                )
              : SizedBox.shrink(),
        ),
      ),
      body: Obx(() {
        return Column(
          children: [
            // Progress bar
            _progressBar(c),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: c.currentStep.value == 0
                    ? _step1PersonalDetails(c, context)
                    : _step2GovtId(c),
              ),
            ),

            // Bottom button
            _bottomButton(c),
          ],
        );
      }),
    );
  }

  Widget _progressBar(DriverOnboardingController c) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${c.currentStep.value + 1} of 2',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              Spacer(),
              Text(
                c.currentStep.value == 0
                    ? 'Personal Details'
                    : 'ID Verification',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _accent,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: (c.currentStep.value + 1) / 2,
            backgroundColor: Colors.grey.shade200,
            color: _accent,
            minHeight: 4.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Personal Details ───
  Widget _step1PersonalDetails(
    DriverOnboardingController c,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('👋 Tell us about yourself'),
        SizedBox(height: 6.h),
        Text(
          'This helps us personalize your experience',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(height: 24.h),

        _inputField(
          'Full Name *',
          c.nameController,
          Icons.person,
          hint: 'Enter your full name',
        ),
        SizedBox(height: 16.h),

        _inputField(
          'Email (optional)',
          c.emailController,
          Icons.email,
          hint: 'yourname@email.com',
          keyboard: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),

        _inputField(
          'Address *',
          c.addressController,
          Icons.home,
          hint: 'Your home/contact address',
          maxLines: 2,
        ),
        SizedBox(height: 16.h),

        // Gender
        Text(
          'Gender *',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Wrap(
            spacing: 10,
            children: ['Male', 'Female', 'Other'].map((g) {
              final selected = c.gender.value == g;
              return ChoiceChip(
                label: Text(
                  g,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: selected ? Colors.white : Colors.black87,
                  ),
                ),
                selected: selected,
                selectedColor: _accent,
                backgroundColor: Colors.grey.shade100,
                onSelected: (_) => c.gender.value = g,
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16.h),

        // DOB
        Text(
          'Date of Birth (optional)',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => InkWell(
            onTap: () => c.pickDob(context),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake, size: 20.w, color: _accent),
                  SizedBox(width: 12.w),
                  Text(
                    c.dob.value != null
                        ? '${c.dob.value!.day}/${c.dob.value!.month}/${c.dob.value!.year}'
                        : 'Select date of birth',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: c.dob.value != null
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 2: Government ID ───
  Widget _step2GovtId(DriverOnboardingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('🪪 Identity Verification'),
        SizedBox(height: 6.h),
        Text(
          'Upload any one government ID to verify your identity',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(height: 24.h),

        // ID Type selector
        Text(
          'ID Type *',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: c.selectedIdType.value,
                isExpanded: true,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                items: c.idTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) =>
                    c.selectedIdType.value = v ?? c.selectedIdType.value,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        _inputField(
          'ID Number *',
          c.idNumberController,
          Icons.credit_card,
          hint: 'Enter your ID number',
        ),
        SizedBox(height: 20.h),

        // Front photo
        Text(
          'ID Front Photo *',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => _photoUploader(
            path: c.idFrontPath.value,
            label: 'Upload front of your ID',
            onTap: () => c.pickIdPhoto(isFront: true),
          ),
        ),
        SizedBox(height: 16.h),

        // Back photo (optional)
        Text(
          'ID Back Photo (optional)',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => _photoUploader(
            path: c.idBackPath.value,
            label: 'Upload back of your ID',
            onTap: () => c.pickIdPhoto(isFront: false),
          ),
        ),
      ],
    );
  }

  // ─── Bottom button ───
  Widget _bottomButton(DriverOnboardingController c) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: MediaQuery.of(Get.context!).padding.bottom + 16,
        top: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: c.isLoading.value ? null : c.nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child: c.isLoading.value
                ? SizedBox(
                    height: 22.h,
                    width: 22.w,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    c.currentStep.value == 1 ? 'Complete Setup' : 'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ─── Reusable Widgets ───
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hint,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(fontSize: 13.sp),
        hintStyle: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: Colors.grey.shade400,
        ),
        prefixIcon: Icon(icon, size: 20.w, color: _accent),
        filled: false,
        fillColor: Colors.grey.shade50,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: _accent, width: 2),
        ),
      ),
    );
  }

  Widget _photoUploader({
    required String path,
    required String label,
    required VoidCallback onTap,
  }) {
    final hasPhoto = path.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: hasPhoto ? _accent.withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasPhoto ? _accent.withOpacity(0.3) : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: hasPhoto
            ? Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 22.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Photo selected',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: _accent,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '(tap to change)',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 32.w,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
