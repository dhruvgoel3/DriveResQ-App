import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class SafetyTipsSection extends StatelessWidget {
  const SafetyTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔒 Title
          Text(
            "Safety Tips",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 12.h),

          // 🧱 Cards Row
          Row(
            children: [
              Flexible(
                child: _SafetyTipCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.orange,
                  title: "Stay in Vehicle",
                  subtitle: "Keep your doors locked until help arrives.",
                ),
              ),
              SizedBox(width: 12.w),
              Flexible(
                child: _SafetyTipCard(
                  icon: Icons.lightbulb_outline,
                  iconColor: Colors.blue,
                  title: "Hazard Lights",
                  subtitle: "Turn on hazard lights to stay visible.",
                ),
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
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔔 Icon
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.w),
            ),

            SizedBox(height: 10.h),

            // 📝 Title
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 4.h),

            // 📄 Subtitle
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
