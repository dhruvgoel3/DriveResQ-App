import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetyTipsSection extends StatelessWidget {
  const SafetyTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔒 Title
          Text(
            "Safety Tips",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // 🧱 Cards Row
          Row(
            children: [
              _SafetyTipCard(
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.orange,
                title: "Stay in Vehicle",
                subtitle: "Keep your doors locked until help arrives.",
              ),
              const SizedBox(width: 12),
              _SafetyTipCard(
                icon: Icons.lightbulb_outline,
                iconColor: Colors.blue,
                title: "Hazard Lights",
                subtitle: "Turn on hazard lights to stay visible.",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafetyTipCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _SafetyTipCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔔 Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),

            const SizedBox(height: 10),

            // 📝 Title
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            // 📄 Subtitle
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
