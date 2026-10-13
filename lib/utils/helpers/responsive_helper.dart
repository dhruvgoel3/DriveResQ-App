import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Centralized responsive scaling utility powered by MediaQuery and safe mobile bounds.
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Current screen width (derived from active BuildContext if available, otherwise Get.width).
  static double get screenWidth {
    try {
      if (Get.context != null) {
        return MediaQuery.sizeOf(Get.context!).width;
      }
      return Get.width;
    } catch (_) {
      return 375.0;
    }
  }

  /// Current screen height (derived from active BuildContext if available, otherwise Get.height).
  static double get screenHeight {
    try {
      if (Get.context != null) {
        return MediaQuery.sizeOf(Get.context!).height;
      }
      return Get.height;
    } catch (_) {
      return 812.0;
    }
  }

  /// Clamped mobile viewport width for layout scaling (prevents massive blowups on tablets/web).
  static double get scaleWidth => screenWidth.clamp(320.0, 480.0);

  /// Clamped mobile viewport height for layout scaling.
  static double get scaleHeight => screenHeight.clamp(568.0, 920.0);
}

/// Extension on num to provide responsive sizing (.w, .h, .r, .sp)
extension ResponsiveExtension on num {
  /// Responsive width based on a 375 logical pixel design width, clamped for safety.
  double get w {
    try {
      return ResponsiveHelper.scaleWidth * (toDouble() / 375.0);
    } catch (_) {
      return toDouble();
    }
  }

  /// Responsive height based on an 812 logical pixel design height, clamped for safety.
  double get h {
    try {
      return ResponsiveHelper.scaleHeight * (toDouble() / 812.0);
    } catch (_) {
      return toDouble();
    }
  }

  /// Responsive radius (scales based on width).
  double get r => w;

  /// Responsive font size that scales smoothly and is safely clamped between 0.85x and 1.15x
  /// of target size, ensuring fonts never blow up on large devices/web or become unreadable on small screens.
  double get sp {
    try {
      final factor = (ResponsiveHelper.scaleWidth / 375.0).clamp(0.85, 1.15);
      return toDouble() * factor;
    } catch (_) {
      return toDouble();
    }
  }
}

/// MediaQuery extensions on [BuildContext] for responsive UI layouts.
extension ResponsiveContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  TextScaler get textScaler => MediaQuery.textScalerOf(this);

  bool get isSmallMobile => screenWidth < 360;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  /// Helper to return breakpoint-specific values.
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? smallMobile,
  }) {
    if (isSmallMobile && smallMobile != null) return smallMobile;
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

/// A robust responsive text widget for buttons that ensures text NEVER clips, truncates,
/// or causes RenderFlex overflow errors across different screen widths and accessibility font scales.
class ResponsiveButtonText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int maxLines;

  const ResponsiveButtonText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.center,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}
