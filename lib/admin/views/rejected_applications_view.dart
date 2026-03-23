import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/verification_controller.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/mechanic_card.dart';

class RejectedApplicationsView extends StatelessWidget {
  const RejectedApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VerificationController>();
    c.fetchMechanics('rejected');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/rejected'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rejected Applications',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Applications that were not approved',
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

                    if (c.mechanics.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(60),
                          child: Column(
                            children: [
                              Icon(
                                Iconsax.like_1,
                                size: 60,
                                color: Colors.green.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No rejected applications',
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
                          '${c.mechanics.length} rejected',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...c.mechanics.map((m) => _rejectedCard(m, c)),
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

  Widget _rejectedCard(Map<String, dynamic> m, VerificationController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          MechanicCard(
            mechanic: m,
            actionLabel: 'View Details',
            onReview: () {
              c.loadMechanicDetails(m['uid']);
              Get.toNamed('/admin/review', arguments: m['uid']);
            },
          ),
          if ((m['rejectionReason'] ?? '').isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                top: 0,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 16,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reason: ${m['rejectionReason']}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const Spacer(),
                  if (m['allowResubmission'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Resubmission Allowed',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
