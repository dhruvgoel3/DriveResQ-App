import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/favorites_controller.dart';
import '../HomePage/create_request_view.dart';
import '../../controllers/create_request_controller.dart';

class MechanicProfileDetailView extends StatelessWidget {
  final Map<String, dynamic> mechanicData;
  static const _accent = Color(0xFF6C63FF);

  const MechanicProfileDetailView({super.key, required this.mechanicData});

  @override
  Widget build(BuildContext context) {
    final FavoritesController favController = Get.find<FavoritesController>();

    final String mechanicId = mechanicData['id'] ?? '';
    final String shopName =
        mechanicData['shopName'] ?? mechanicData['name'] ?? 'Unknown Mechanic';
    final double rating = (mechanicData['rating'] ?? 0.0).toDouble();
    final int reviewCount = (mechanicData['reviewCount'] ?? 0).toInt();
    final double distance = (mechanicData['distance'] ?? 0.0).toDouble();
    final String area = mechanicData['address'] ?? 'Unknown Area';
    final int exp = (mechanicData['experienceYears'] ?? 0).toInt();
    final String specialization =
        (mechanicData['specialization'] is List
            ? (mechanicData['specialization'] as List).join(', ')
            : mechanicData['specialization']) ??
        'General Repair';
    final String profilePhoto = mechanicData['profilePhoto'] ?? '';
    final bool isVerified = mechanicData['verificationStatus'] == 'approved';

    final int baseCharge = (mechanicData['baseCharge'] ?? 0).toInt();
    final int perKm = (mechanicData['perKmCharge'] ?? 0).toInt();

    final List<String> services = List<String>.from(
      mechanicData['servicesOffered'] ?? [],
    );
    final int jobsCompleted = (mechanicData['jobsCompleted'] ?? 0).toInt();
    final String phone = mechanicData['phone'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),
      body: CustomScrollView(
        slivers: [
          // App Bar & Hero Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: _accent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              Obx(() {
                final isFav = favController.isFavorited(mechanicId);
                return IconButton(
                  icon: Icon(
                    isFav ? Iconsax.heart : Iconsax.heart,
                    color: isFav ? Colors.redAccent : Colors.white,
                  ),
                  onPressed: () => favController.toggleFavorite(mechanicId),
                );
              }),
              IconButton(
                icon: const Icon(Iconsax.more, color: Colors.white),
                onPressed: () {
                  // Show more actions: Report, Share
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: profilePhoto.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: profilePhoto,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.3),
                      colorBlendMode: BlendMode.darken,
                    )
                  : Container(
                      color: _accent,
                      child: Center(
                        child: Icon(
                          Iconsax.setting_2,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7FC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identity Header
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                shopName,
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (isVerified)
                              Container(
                                margin: const EdgeInsets.only(left: 12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.verify,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            // Rating Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Iconsax.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                  Text(
                                    " ($reviewCount)",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Experience Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Iconsax.clock,
                                    color: _accent,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$exp Years Exp.",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // About Section
                  _buildSectionContainer(
                    title: "ABOUT",
                    child: Text(
                      mechanicData['bio'] ??
                          "Specializing in $specialization with $exp years of experience. We provide quality roadside assistance and repair services at your location.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),

                  // Contact Info Section
                  _buildSectionContainer(
                    title: "CONTACT INFORMATION",
                    child: Column(
                      children: [
                        _buildContactRow(
                          Iconsax.call,
                          phone,
                          "Call",
                          () => _callMechanic(phone),
                        ),
                        const Divider(height: 24),
                        _buildContactRow(
                          Iconsax.location,
                          area,
                          "Drive",
                          () => _navigateMechanic(area),
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(
                              Iconsax.car,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "${distance.toStringAsFixed(1)} km from your location",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Services Section
                  if (services.isNotEmpty)
                    _buildSectionContainer(
                      title: "SERVICES OFFERED",
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: services.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _accent.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              s,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: _accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Pricing Section
                  _buildSectionContainer(
                    title: "PRICING",
                    child: Column(
                      children: [
                        _buildPricingRow("Base Service Charge", "₹$baseCharge"),
                        const SizedBox(height: 12),
                        _buildPricingRow("Per Kilometer", "₹$perKm"),
                      ],
                    ),
                  ),

                  // Stats Section
                  _buildSectionContainer(
                    title: "STATISTICS",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(jobsCompleted.toString(), "Jobs Done"),
                        _buildStatCard("$rating ⭐", "Rating"),
                        _buildStatCard("<10 min", "Response"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () => _callMechanic(phone),
                icon: const Icon(Iconsax.call, size: 20),
                label: const Text("Call"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _requestService(mechanicId, shopName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.car, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Request Service",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String text,
    String btnText,
    VoidCallback onTap,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            btnText,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  void _callMechanic(String phone) async {
    if (phone.isEmpty) return;
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _navigateMechanic(String area) async {
    final query = Uri.encodeComponent(area);
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _requestService(String mechId, String mechName) {
    // Navigate to create request page, we can pass optional mechId if user wants to direct request
    // Since normal CreateRequestView doesn't take args currently, we just navigate to it normally.
    try {
      // Assuming finding the controller to reset first if it exists
      if (Get.isRegistered<CreateRequestController>()) {
        Get.delete<CreateRequestController>();
      }
    } catch (_) {}
    Get.to(() => CreateRequestView());
    AppSnackbar.info(
      'You are creating a request. (Preferred Mechanic: $mechName)',
      title: 'Direct Request',
    );
  }
}
