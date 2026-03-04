import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Header
                      Text(
                        "Welcome to",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        "DriveResQ",
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Your roadside assistance partner",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Choose role text
                      Text(
                        "I am a...",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Role cards
                      Obx(
                        () => _roleCard(
                          controller: controller,
                          role: 'driver',
                          title: 'Driver',
                          subtitle: 'Need roadside assistance',
                          icon: Icons.directions_car,
                          color: Colors.blue,
                          isSelected: controller.selectedRole.value == 'driver',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => _roleCard(
                          controller: controller,
                          role: 'mechanic',
                          title: 'Mechanic',
                          subtitle: 'Provide roadside assistance',
                          icon: Icons.build,
                          color: Colors.orange,
                          isSelected:
                              controller.selectedRole.value == 'mechanic',
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 20),

                      // Continue button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 56,
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
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Continue",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
