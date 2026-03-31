import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/verification_controller.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/mechanic_card.dart';

class ApprovedMechanicsView extends StatelessWidget {
  const ApprovedMechanicsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VerificationController>();
    c.fetchApplications('approved');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/approved'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Approved Mechanics',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All verified and active mechanics',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  Obx(() {
                    if (c.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(60),
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF9800),
                          ),
                        ),
                      );
                    }

                    if (c.applications.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(60),
                          child: Column(
                            children: [
                              Icon(
                                Iconsax.people,
                                size: 60,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No approved mechanics yet',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${c.applications.length} mechanic${c.applications.length > 1 ? 's' : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...c.applications.map(
                          (m) => MechanicCard(
                            mechanic: m,
                            actionLabel: 'View Profile',
                            onReview: () {
                              c.loadApplicationDetails(m['uid']);
                              Get.toNamed('/admin/review', arguments: m['uid']);
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
