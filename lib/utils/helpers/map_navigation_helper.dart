import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class MapsNavigationHelper {
  static Future<void> startNavigation({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final url = Platform.isAndroid
        ? Uri.parse("google.navigation:q=$destLat,$destLng&mode=d")
        : Uri.parse(
            "http://maps.apple.com/?saddr=$originLat,$originLng&daddr=$destLat,$destLng",
          );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not open navigation';
    }
  }
}
