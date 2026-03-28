import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/onboarding_controller.dart';
import 'step3_documents.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class Step2ProfessionalDetails extends StatelessWidget {
  const Step2ProfessionalDetails({super.key});

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
                    _buildShopName(c),
                    SizedBox(height: 20.h),
                    _buildShopAddress(c),
                    SizedBox(height: 20.h),
                    _buildShopPhoto(c),
                    SizedBox(height: 20.h),
                    _buildExperience(c),
                    SizedBox(height: 24.h),
                    _buildSpecializations(c),
                    SizedBox(height: 24.h),
                    _buildServices(c),
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
          c.currentStep.value = 1;
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
                  'Professional Details',
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
          'Professional Details',
          style: GoogleFonts.poppins(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Tell us about your shop and expertise',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildShopName(MechanicOnboardingController c) {
    return _inputField(
      controller: c.shopNameController,
      label: 'Shop / Garage Name *',
      hint: 'Enter your shop name',
      icon: Iconsax.shop,
    );
  }

  Widget _buildShopAddress(MechanicOnboardingController c) {
    return _inputField(
      controller: c.shopAddressController,
      label: 'Shop Address *',
      hint: 'Enter shop address',
      icon: Iconsax.location,
      maxLines: 2,
    );
  }

  Widget _buildShopPhoto(MechanicOnboardingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop Photo *',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() {
          return GestureDetector(
            onTap: () => c.pickImage(c.shopPhoto),
            child: Container(
              height: 160.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                image: c.shopPhoto.value != null
                    ? DecorationImage(
                        image: FileImage(c.shopPhoto.value!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: c.shopPhoto.value == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.camera,
                          size: 40.w,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Tap to add shop photo',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExperience(MechanicOnboardingController c) {
    return _inputField(
      controller: c.experienceController,
      label: 'Years of Experience *',
      hint: 'e.g. 5',
      icon: Iconsax.clock,
      type: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildSpecializations(MechanicOnboardingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specializations *',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Select all that apply',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MechanicOnboardingController.allSpecializations.map((
              item,
            ) {
              final selected = c.specializations.contains(item);
              return GestureDetector(
                onTap: () => c.toggleSpecialization(item),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? Color(0xFFFF9800) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: selected
                          ? Color(0xFFFF9800)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildServices(MechanicOnboardingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Offered',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Select the services you offer',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MechanicOnboardingController.allServices.map((item) {
              final selected = c.servicesOffered.contains(item);
              return GestureDetector(
                onTap: () => c.toggleService(item),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Color(0xFFFF9800).withOpacity(0.15)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: selected
                          ? Color(0xFFFF9800)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        Icon(
                          Iconsax.tick_circle,
                          size: 16.w,
                          color: Color(0xFFFF9800),
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? Color(0xFFFF9800)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
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
            if (c.currentStep.value == 3) {
              Get.to(() => Step3Documents());
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
    int maxLines = 1,
    List<TextInputFormatter>? formatters,
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
          maxLines: maxLines,
          inputFormatters: formatters,
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
