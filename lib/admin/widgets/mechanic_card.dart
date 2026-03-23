import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MechanicCard extends StatelessWidget {
  final Map<String, dynamic> mechanic;
  final VoidCallback onReview;
  final String? actionLabel;

  const MechanicCard({
    super.key,
    required this.mechanic,
    required this.onReview,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final name = mechanic['fullName'] ?? 'Unknown';
    final shop = mechanic['shopName'] ?? 'No shop';
    final phone = mechanic['phone'] ?? '';
    final email = mechanic['email'] ?? '';
    final photoUrl = mechanic['profilePhotoUrl'] ?? '';
    final submittedAt = mechanic['onboardingSubmittedAt'];
    final status = mechanic['verificationStatus'] ?? 'pending';

    String daysPending = '';
    if (submittedAt != null) {
      final submitted = (submittedAt as Timestamp).toDate();
      final days = DateTime.now().difference(submitted).inDays;
      daysPending = days == 0 ? 'Today' : '$days day${days > 1 ? 's' : ''} ago';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Photo
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
            backgroundImage: photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            child: photoUrl.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF9800),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  shop,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (phone.isNotEmpty) ...[
                      Icon(Iconsax.call, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (email.isNotEmpty) ...[
                      Icon(Iconsax.sms, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          email,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Status + Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusBadge(status),
              if (daysPending.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  daysPending,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionLabel ?? 'Review',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'approved':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        label = 'Approved';
        break;
      case 'rejected':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        label = 'Rejected';
        break;
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
