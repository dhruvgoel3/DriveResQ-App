import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/verification_controller.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/mechanic_card.dart';

class PendingVerificationsView extends StatelessWidget {
  const PendingVerificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VerificationController>();
    c.fetchMechanics('pending');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/pending'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending Verifications',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Review and approve mechanic applications',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => c.fetchMechanics('pending'),
                        icon: const Icon(Iconsax.refresh, size: 18),
                        label: Text(
                          'Refresh',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey.shade700,
                          elevation: 0,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
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
                      return _emptyState();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${c.mechanics.length} application${c.mechanics.length > 1 ? 's' : ''} pending',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...c.mechanics.map(
                          (m) => MechanicCard(
                            mechanic: m,
                            actionLabel: 'Review Application',
                            onReview: () {
                              c.loadMechanicDetails(m['uid']);
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

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          children: [
            Icon(Iconsax.tick_circle, size: 72, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text(
              'All caught up! 🎉',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No pending verifications at the moment.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
