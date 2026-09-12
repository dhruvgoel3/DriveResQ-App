import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

/// Rich driver dashboard home content — OTP tip, safety tips, how-it-works.
class SafetyTipsSection extends StatelessWidget {
  const SafetyTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── OTP SECURITY TIP ──
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withValues(alpha: 0.12),
                AppColors.warning.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Iconsax.eye_slash,
                  color: AppColors.secondary,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Keep Your OTP Hidden",
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Do not share your verification code until the mechanic has completed the repair. Only reveal it to confirm job completion.",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // ── SAFETY TIPS ──
        Text(
          "Safety Tips",
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 120.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: EdgeInsets.only(right: 4.w),
            children: [
              _SafetyTipCard(
                icon: Iconsax.warning_2,
                iconColor: Colors.orange,
                title: "Stay in Vehicle",
                subtitle: "Keep doors locked until help arrives.",
                gradient: [Colors.orange.shade50, Colors.orange.shade100],
              ),
              SizedBox(width: 10.w),
              _SafetyTipCard(
                icon: Iconsax.lamp_charge,
                iconColor: Colors.blue,
                title: "Hazard Lights",
                subtitle: "Turn on lights to stay visible.",
                gradient: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              SizedBox(width: 10.w),
              _SafetyTipCard(
                icon: Iconsax.shield_tick,
                iconColor: Colors.green,
                title: "Verify Mechanic",
                subtitle: "Check profile before confirming.",
                gradient: [Colors.green.shade50, Colors.green.shade100],
              ),
              SizedBox(width: 10.w),
              _SafetyTipCard(
                icon: Iconsax.location,
                iconColor: Colors.purple,
                title: "Share Location",
                subtitle: "Share with a trusted contact.",
                gradient: [Colors.purple.shade50, Colors.purple.shade100],
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // ── HOW IT WORKS ──
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.06),
                AppColors.primary.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: AppColors.primary,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "How DriveResQ Works",
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const _StepRow(
                number: "1",
                text: "Create a help request with your issue",
              ),
              SizedBox(height: 10.h),
              const _StepRow(
                number: "2",
                text: "Nearby verified mechanics get notified",
              ),
              SizedBox(height: 10.h),
              const _StepRow(
                number: "3",
                text: "Accept the mechanic and get an OTP",
              ),
              SizedBox(height: 10.h),
              const _StepRow(
                number: "4",
                text: "Mechanic fixes your vehicle on-site",
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),
      ],
    );
  }
}

// ── Safety Tip Card (compact) ──
class _SafetyTipCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _SafetyTipCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: iconColor, size: 18.w),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Flexible(
            child: Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Row for How-it-Works ──
class _StepRow extends StatelessWidget {
  final String number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26.w,
          height: 26.h,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
