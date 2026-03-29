import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/onboarding_controller.dart';
import 'step6_terms.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class Step5Availability extends StatelessWidget {
  const Step5Availability({super.key});

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
                    _buildWorkingHours(c, context),
                    SizedBox(height: 24.h),
                    _buildAvailableDays(c),
                    SizedBox(height: 24.h),
                    _buildServiceRadius(c),
                    SizedBox(height: 24.h),
                    _buildPricingSection(c),
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
          c.currentStep.value = 4;
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
                    color: const Color(0xFFFF9800),
                  ),
                ),
                Text(
                  'Availability & Pricing',
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
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF9800),
                ),
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
          'Availability & Pricing',
          style: GoogleFonts.poppins(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Set your working hours and service charges',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingHours(
    MechanicOnboardingController c,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Working Hours',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _timeCard(
                  label: 'Start Time',
                  time: c.workingHoursStart.value,
                  onTap: () => c.pickStartTime(context),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            const Icon(Iconsax.arrow_right, color: Color(0xFFFF9800)),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(
                () => _timeCard(
                  label: 'End Time',
                  time: c.workingHoursEnd.value,
                  onTap: () => c.pickEndTime(context),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _timeCard({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableDays(MechanicOnboardingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Days *',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MechanicOnboardingController.allDays.map((day) {
              final selected = c.availableDays.contains(day);
              return GestureDetector(
                onTap: () => c.toggleDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFF9800)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFF9800)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    day.substring(0, 3),
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.grey.shade600,
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

  Widget _buildServiceRadius(MechanicOnboardingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Radius',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '5 km',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      '${c.serviceRadius.value.round()} km',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                    Text(
                      '50 km',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: const SliderThemeData(
                    activeTrackColor: Color(0xFFFF9800),
                    inactiveTrackColor: Color(0xFFFFE0B2),
                    thumbColor: Color(0xFFFF9800),
                    overlayColor: Color(0x29FF9800),
                  ),
                  child: Slider(
                    value: c.serviceRadius.value,
                    min: 5,
                    max: 50,
                    divisions: 45,
                    onChanged: (v) => c.serviceRadius.value = v,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection(MechanicOnboardingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        _priceField(c.baseChargeController, 'Base Service Charge *', '₹ 200'),
        SizedBox(height: 16.h),
        _priceField(c.perKmChargeController, 'Per KM Charge *', '₹ 15'),
        SizedBox(height: 16.h),
        _priceField(
          c.emergencySurchargeController,
          'Emergency Surcharge %',
          '20',
        ),
      ],
    );
  }

  Widget _priceField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          cursorColor: const Color(0xFFFF9800),
          style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
            prefixIcon: Icon(
              label.contains('%') ? Iconsax.percentage_circle : Iconsax.money,
              color: const Color(0xFFFF9800),
              size: 20.w,
            ),
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

  Widget _buildContinueButton(MechanicOnboardingController c) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: () {
            c.nextStep();
            if (c.currentStep.value == 6) {
              Get.to(() => const Step6Terms());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
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
