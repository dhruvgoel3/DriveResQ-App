import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../controllers/favorites_controller.dart';
import '../mechanic_profile_detail_view.dart';

class MechanicCardWidget extends StatelessWidget {
  final Map<String, dynamic> mechanic;
  static const _accent = Color(0xFF6C63FF);

  const MechanicCardWidget({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    final FavoritesController favController = Get.find<FavoritesController>();
    final String mechanicId = mechanic['id'] ?? '';
    final String shopName =
        mechanic['shopName'] ?? mechanic['name'] ?? 'Unknown Mechanic';
    final double rating = (mechanic['rating'] ?? 0.0).toDouble();
    final int reviewCount = (mechanic['reviewCount'] ?? 0).toInt();
    final double distance = (mechanic['distance'] ?? 0.0).toDouble();
    final String area = mechanic['address'] ?? 'Unknown Area';
    final int exp = (mechanic['experienceYears'] ?? 0).toInt();
    final String specialization =
        (mechanic['specialization'] is List
            ? (mechanic['specialization'] as List).firstOrNull
            : mechanic['specialization']) ??
        'General';

    final String profilePhoto = mechanic['profilePhoto'] ?? '';
    final bool isOnline = mechanic['isOnline'] == true;
    final bool isVerified = mechanic['verificationStatus'] == 'approved';

    final int baseCharge = (mechanic['baseCharge'] ?? 0).toInt();
    final int perKm = (mechanic['perKmCharge'] ?? 0).toInt();

    final List<String> services = List<String>.from(
      mechanic['servicesOffered'] ?? [],
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOnline ? Colors.green : Colors.grey.shade300,
                        width: 2,
                      ),
                      image: profilePhoto.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(profilePhoto),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey.shade100,
                    ),
                    child: profilePhoto.isEmpty
                        ? Center(
                            child: Text(
                              shopName.isNotEmpty
                                  ? shopName[0].toUpperCase()
                                  : 'M',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                        : null,
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            shopName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              " ($reviewCount)",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$specialization • $exp yrs exp",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Iconsax.location, color: _accent, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${distance.toStringAsFixed(1)} km away • $area",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Services
          if (services.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Iconsax.setting_2, color: Colors.grey.shade400, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        services.take(3).map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: _accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList()..addAll(
                          services.length > 3
                              ? [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "+${services.length - 3} more",
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ]
                              : [],
                        ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),

          // Pricing Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Iconsax.money, color: Colors.green.shade700, size: 16),
                const SizedBox(width: 6),
                Text(
                  "Base: ₹$baseCharge  |  Per KM: ₹$perKm",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status Badges
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (isVerified)
                  _buildBadge(
                    Iconsax.tick_circle,
                    "Verified",
                    Colors.lightGreen,
                  ),
                const SizedBox(width: 8),
                if (isOnline)
                  _buildBadge(Iconsax.clock, "Available Now", Colors.green),
                const SizedBox(width: 8),
                _buildBadge(Iconsax.flash, "Quick Response", Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              // Call
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _callMechanic(mechanic['phone'] ?? ''),
                  icon: const Icon(Iconsax.call, size: 18),
                  label: const Text("Call"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    side: const BorderSide(color: _accent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // View Profile
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(
                      () => MechanicProfileDetailView(mechanicData: mechanic),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("View Profile"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Favorite Button
          Center(
            child: Obx(() {
              final isFav = favController.isFavorited(mechanicId);
              return InkWell(
                onTap: () => favController.toggleFavorite(mechanicId),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFav ? Iconsax.heart : Iconsax.heart,
                        color: isFav ? Colors.redAccent : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFav ? "Favorited" : "Add to Favorites",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isFav
                              ? Colors.redAccent
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _callMechanic(String phone) async {
    if (phone.isEmpty) {
      AppSnackbar.error('Phone number not available');
      return;
    }
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      AppSnackbar.error('Could not launch phone dialer');
    }
  }
}
