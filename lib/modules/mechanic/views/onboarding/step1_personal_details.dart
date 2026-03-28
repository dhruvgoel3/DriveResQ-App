import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/onboarding_controller.dart';
import 'step2_professional_details.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class Step1PersonalDetails extends StatelessWidget {
  const Step1PersonalDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MechanicOnboardingController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(c),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 32.h),
                    _buildProfilePhoto(c),
                    SizedBox(height: 28.h),
                    _buildFullName(c),
                    SizedBox(height: 20.h),
                    _buildDobPicker(c, context),
                    SizedBox(height: 20.h),
                    _buildGenderPicker(c),
                    SizedBox(height: 20.h),
                    _buildEmail(c),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            _buildContinueButton(c),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Iconsax.arrow_left_2, color: Colors.black87, size: 20.w),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Mechanic Registration',
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressBar(MechanicOnboardingController c) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${c.currentStep.value} of 6',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF9800),
                  ),
                ),
                Text(
                  'Personal Details',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: c.currentStep.value / 6,
                minHeight: 6.h,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Details',
          style: GoogleFonts.poppins(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Tell us about yourself to set up your profile',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto(MechanicOnboardingController c) {
    return Center(
      child: Obx(() {
        return GestureDetector(
          onTap: () => c.pickImage(c.profilePhoto),
          child: Stack(
            children: [
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF9800).withOpacity(0.1),
                  border: Border.all(
                    color: Color(0xFFFF9800).withOpacity(0.3),
                    width: 3.w,
                  ),
                  image: c.profilePhoto.value != null
                      ? DecorationImage(
                          image: FileImage(c.profilePhoto.value!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: c.profilePhoto.value == null
                    ? Icon(Iconsax.user, size: 50.w, color: Color(0xFFFF9800))
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF9800),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.camera, size: 18.w, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFullName(MechanicOnboardingController c) {
    return _inputField(
      controller: c.nameController,
      label: 'Full Name *',
      hint: 'Enter your full name',
      icon: Iconsax.user,
    );
  }

  Widget _buildDobPicker(MechanicOnboardingController c, BuildContext context) {
    return Obx(() {
      final hasDate = c.dob.value != null;
      return GestureDetector(
        onTap: () => c.pickDob(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Iconsax.calendar, color: Color(0xFFFF9800), size: 22.w),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  hasDate
                      ? '${c.dob.value!.day}/${c.dob.value!.month}/${c.dob.value!.year}'
                      : 'Date of Birth *',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: hasDate ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
              ),
              Icon(Iconsax.arrow_down_1, color: Colors.grey.shade400),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGenderPicker(MechanicOnboardingController c) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Iconsax.profile_2user, color: Color(0xFFFF9800), size: 22.w),
            SizedBox(width: 14.w),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: c.gender.value.isEmpty ? null : c.gender.value,
                  hint: Text(
                    'Gender *',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 15.sp,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 15.sp,
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => c.gender.value = v ?? '',
                  isExpanded: true,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmail(MechanicOnboardingController c) {
    return _inputField(
      controller: c.emailController,
      label: 'Email (Optional)',
      hint: 'Enter your email address',
      icon: Iconsax.sms,
      type: TextInputType.emailAddress,
    );
  }

  Widget _buildContinueButton(MechanicOnboardingController c) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: () {
            c.nextStep();
            if (c.currentStep.value == 2) {
              Get.to(() => Step2ProfessionalDetails());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF9800),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Text(
            'Continue',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: type,
          cursorColor: const Color(0xFFFF9800),
          style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: const Color(0xFFFF9800), size: 22.w),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(
                color: Color(0xFFFF9800),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
