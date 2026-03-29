import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/verification_controller.dart';
import '../widgets/review_tabs/decision_dialogs.dart';
import '../widgets/review_tabs/personal_tab.dart';
import '../widgets/review_tabs/professional_tab.dart';
import '../widgets/review_tabs/documents_tab.dart';
import '../widgets/review_tabs/bank_tab.dart';
import '../widgets/review_tabs/availability_tab.dart';
import '../widgets/review_tabs/review_decision_tab.dart';

class ReviewApplicationView extends StatefulWidget {
  const ReviewApplicationView({super.key});

  @override
  State<ReviewApplicationView> createState() => _ReviewApplicationViewState();
}

class _ReviewApplicationViewState extends State<ReviewApplicationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VerificationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Obx(() {
        final m = c.selectedMechanic.value;
        if (m == null || c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF9800)),
          );
        }

        return Row(
          children: [
            // Left back panel
            Container(
              width: 60,
              color: const Color(0xFF1A1D23),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Column(
                children: [
                  // Top header
                  _buildHeader(context, m, c),
                  // Tab bar
                  _buildTabBar(),
                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        PersonalTab(mechanicData: m),
                        ProfessionalTab(mechanicData: m),
                        DocumentsTab(mechanicData: m),
                        BankTab(mechanicData: m),
                        AvailabilityTab(mechanicData: m),
                        ReviewDecisionTab(mechanicData: m, controller: c),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Map<String, dynamic> m,
    VerificationController c,
  ) {
    final name = m['fullName'] ?? 'Unknown';
    final phone = m['phone'] ?? '';
    final email = m['email'] ?? '';
    final photo = m['profilePhotoUrl'] ?? '';
    final uid = m['uid'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
            backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
            child: photo.isEmpty
                ? Text(
                    name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF9800),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (phone.isNotEmpty) ...[
                      Icon(Iconsax.call, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                    if (email.isNotEmpty) ...[
                      Icon(Iconsax.sms, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Submitted: ${c.formatDate(m['onboardingSubmittedAt'])}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 12),
              // Always-visible Approve / Reject buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => DecisionDialogs.showApproveDialog(
                      context,
                      c,
                      uid,
                      name,
                    ),
                    icon: const Icon(Iconsax.tick_circle, size: 18),
                    label: Text(
                      'Approve',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        DecisionDialogs.showRejectDialog(context, c, uid, name),
                    icon: const Icon(Iconsax.close_square, size: 18),
                    label: Text(
                      'Reject',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFFFF9800),
        unselectedLabelColor: Colors.grey.shade500,
        indicatorColor: const Color(0xFFFF9800),
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
        tabs: const [
          Tab(text: 'Personal'),
          Tab(text: 'Professional'),
          Tab(text: 'Documents'),
          Tab(text: 'Bank Details'),
          Tab(text: 'Availability'),
          Tab(text: 'Review & Decision'),
        ],
      ),
    );
  }
}
