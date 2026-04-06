import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

/// A reusable widget that wraps a dashboard-level screen and handles
/// the Android back-button in a production-ready manner:
///
/// 1. If a non-Home tab is active → switch to Home tab first.
/// 2. If already on Home tab → show a "Tap back again to exit" snackbar.
/// 3. On second back-press within 2 seconds → exit the app gracefully.
class ExitGuard extends StatefulWidget {
  /// The child widget (the actual dashboard scaffold).
  final Widget child;

  /// Getter for the current tab index (0 = Home).
  final int Function() currentTab;

  /// Callback to switch back to the Home tab (index 0).
  final VoidCallback onSwitchToHome;

  const ExitGuard({
    super.key,
    required this.child,
    required this.currentTab,
    required this.onSwitchToHome,
  });

  @override
  State<ExitGuard> createState() => _ExitGuardState();
}

class _ExitGuardState extends State<ExitGuard> {
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        // Step 1: If user is NOT on the Home tab, go to Home tab first.
        if (widget.currentTab() != 0) {
          widget.onSwitchToHome();
          return;
        }

        // Step 2: If user IS on the Home tab, implement double-back-to-exit.
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          _showExitSnackBar(context);
          return;
        }

        // Step 3: Second back press within 2 seconds → exit app.
        SystemNavigator.pop();
      },
      child: widget.child,
    );
  }

  void _showExitSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.exit_to_app, color: Colors.white, size: 20),
            SizedBox(width: 8.w),
            Text(
              'Tap back again to exit',
              style: AppTextStyles.body2.copyWith(color: Colors.white),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
