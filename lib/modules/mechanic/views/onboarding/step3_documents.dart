import 'package:iconsax/iconsax.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/onboarding_controller.dart';
import 'step4_bank_details.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class Step3Documents extends StatelessWidget {
  const Step3Documents({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MechanicOnboardingController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(c),
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
                    SizedBox(height: 28.h),
                    _buildDocCard(
                      label: 'Aadhaar Card - Front *',
                      file: c.aadhaarFront,
                      onTap: () => c.pickImage(c.aadhaarFront),
                      icon: Iconsax.card,
                    ),
                    SizedBox(height: 16.h),
                    _buildDocCard(
                      label: 'Aadhaar Card - Back *',
                      file: c.aadhaarBack,
                      onTap: () => c.pickImage(c.aadhaarBack),
                      icon: Iconsax.card,
                    ),
                    SizedBox(height: 20.h),
                    _buildAadhaarNumber(c),
                    SizedBox(height: 20.h),
                    _buildDocCard(
                      label: 'PAN Card (Optional)',
                      file: c.panCard,
                      onTap: () => c.pickImage(c.panCard),
                      icon: Iconsax.award,
                    ),
                    SizedBox(height: 16.h),
                    _buildDocCard(
                      label: 'Trade License / Work Permit (Optional)',
                      file: c.tradeLicense,
                      onTap: () => c.pickImage(c.tradeLicense),
                      icon: Iconsax.document_text,
                    ),
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

  AppBar _buildAppBar(MechanicOnboardingController c) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Iconsax.arrow_left_2, color: Colors.black87, size: 20.w),
        onPressed: () {
          c.currentStep.value = 2;
          Get.back();
        },
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
    return Obx(
      () => Container(
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
                  'Documents',
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
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Upload',
          style: GoogleFonts.poppins(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Upload your documents for verification',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildDocCard({
    required String label,
    required Rxn<File> file,
    required VoidCallback onTap,
    required IconData icon,
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
        Obx(() {
          final hasFile = file.value != null;
          return GestureDetector(
            onTap: onTap,
            child: Container(
              height: hasFile ? 180 : 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: hasFile ? null : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: hasFile ? Color(0xFF4CAF50) : Colors.grey.shade200,
                  width: 1.5,
                ),
                image: hasFile
                    ? DecorationImage(
                        image: FileImage(file.value!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: hasFile
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: EdgeInsets.all(8.w),
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.tick_circle,
                          size: 16.w,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 32.w, color: Colors.grey.shade400),
                        SizedBox(height: 8.h),
                        Text(
                          'Tap to upload',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAadhaarNumber(MechanicOnboardingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aadhaar Number *',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: c.aadhaarNumberController,
          keyboardType: TextInputType.number,
          maxLength: 12,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          cursorColor: const Color(0xFFFF9800),
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            letterSpacing: 2,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'XXXX XXXX XXXX',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              letterSpacing: 2,
            ),
            prefixIcon: Icon(
              Iconsax.finger_scan,
              color: const Color(0xFFFF9800),
              size: 22.w,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            counterText: '',
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
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(Iconsax.lock, size: 14.w, color: Colors.grey.shade400),
            SizedBox(width: 4.w),
            Text(
              'Your Aadhaar number will be securely stored',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ],
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
            if (c.currentStep.value == 4) {
              Get.to(() => Step4BankDetails());
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
}
