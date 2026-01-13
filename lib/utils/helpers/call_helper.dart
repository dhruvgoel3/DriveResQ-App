import 'package:url_launcher/url_launcher.dart';

class CallHelper {
  static Future<void> callNumber(String phone) async {
    if (phone.isEmpty) {
      print("📞 Phone number is empty");
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print("❌ Cannot launch dialer for $phone");
      }
    } catch (e) {
      print("❌ Call error: $e");
    }
  }
}
