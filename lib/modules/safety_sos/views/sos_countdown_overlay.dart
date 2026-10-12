import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/helpers/responsive_helper.dart';
import '../controllers/safety_sos_controller.dart';

/// Full-screen countdown overlay shown when a shake (or manual SOS) is detected.
///
/// Displayed via [Get.dialog] with [barrierDismissible: false] so the user
/// must explicitly press CANCEL SOS.
class SosCountdownOverlay extends StatelessWidget {
  const SosCountdownOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SafetySosController>();

    return PopScope(
      canPop: false, // Hardware back button cannot dismiss overlay
      child: Scaffold(
        backgroundColor: const Color(0xFFDC2626), // Emergency red
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Warning Icon ──
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 48.w,
                  color: Colors.white,
                  semanticLabel: 'Emergency warning',
                ),
              ),
              SizedBox(height: 24.h),

              // ── Title ──
              Text(
                'Emergency SOS Detected',
                textAlign: TextAlign.center,
                semanticsLabel: 'Emergency SOS Detected',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Sending emergency alerts in…',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),

              SizedBox(height: 48.h),

              // ── Countdown Number ──
              Obx(() {
                final secs = controller.countdownSeconds.value;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Text(
                    '$secs',
                    key: ValueKey(secs),
                    textAlign: TextAlign.center,
                    semanticsLabel: '$secs seconds remaining',
                    style: GoogleFonts.poppins(
                      fontSize: 96.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                );
              }),

              SizedBox(height: 16.h),
              Text(
                'seconds',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // ── Cancel Button ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 64.h,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.cancelCountdown();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC2626),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'CANCEL SOS',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFDC2626),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                'Press CANCEL SOS to stop the alert.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
