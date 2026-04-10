import 'package:url_launcher/url_launcher.dart';

class CallHelper {
  static Future<void> callNumber(String phone) async {
    if (phone.isEmpty) {
      /* print stripped */
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        /* print stripped */
      }
    } catch (e) {
      /* print stripped */
    }
  }
}
