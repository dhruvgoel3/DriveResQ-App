import 'package:get/get.dart';

extension ResponsiveExtension on num {
  /// Responsive width based on a 375 logical pixel design width.
  double get w {
    try {
      return Get.width * (toDouble() / 375.0);
    } catch (_) {
      return toDouble();
    }
  }

  /// Responsive height based on an 812 logical pixel design height.
  double get h {
    try {
      return Get.height * (toDouble() / 812.0);
    } catch (_) {
      return toDouble();
    }
  }

  /// Responsive radius (scales based on width).
  double get r => w;

  /// Responsive font size (scales based on width to maintain readability).
  double get sp => w;
}
