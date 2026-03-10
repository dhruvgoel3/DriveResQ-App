import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class CallHelper {
  static Future<void> callNumber(String phone) async {
    if (phone.isEmpty) {
      debugPrint("Phone number is empty");
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Cannot launch dialer for $phone");
      }
    } catch (e) {
      debugPrint("Call error: $e");
    }
  }
}
