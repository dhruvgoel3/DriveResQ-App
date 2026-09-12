import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),

                      // Header
                      Text(
                        "Welcome to",
                        style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        "DriveResQ",
                        style: GoogleFonts.poppins(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Your roadside assistance partner",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),

                      SizedBox(height: 48.h),

                      // Choose role text
                      Text(
                        "I am a...",
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Role cards
                      Obx(
                        () => _roleCard(
                          controller: controller,
                          role: 'driver',
                          title: 'Driver',
                          subtitle: 'Need roadside assistance',
                          icon: Iconsax.car,
                          color: Colors.blue,
                          isSelected: controller.selectedRole.value == 'driver',
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Obx(
                        () => _roleCard(
                          controller: controller,
                          role: 'mechanic',
                          title: 'Mechanic',
                          subtitle: 'Provide roadside assistance',
                          icon: Iconsax.setting_2,
                          color: Colors.orange,
                          isSelected:
                              controller.selectedRole.value == 'mechanic',
                        ),
                      ),

                      const Spacer(),
                      SizedBox(height: 20.h),

                      // Continue button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: controller.selectedRole.value.isEmpty
                                ? null
                                : () {
                                    Get.toNamed('/login');
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              "Continue",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _roleCard({
    required AuthController controller,
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, size: 40.w, color: color),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  Iconsax.tick_circle,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
