import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';

class CallHelper {
  static Future<void> callNumber(String phone) async {
    if (phone.isEmpty) {
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppSnackbar.error('Could not open the phone dialer');
      }
    } catch (e) {
      debugPrint('CallHelper.callNumber failed: $e');
      AppSnackbar.error('Could not open the phone dialer');
    }
  }
}
