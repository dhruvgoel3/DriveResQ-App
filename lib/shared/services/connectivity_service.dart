import 'dart:io';
import 'package:flutter/foundation.dart';

/// A robust utility service to monitor and verify network connectivity.
///
/// This service performs a reliable DNS lookup to 'google.com' to ensure
/// the device has actual internet access, rather than just being connected
/// to a local Wi-Fi router with no backhaul.
class ConnectivityService {
  /// Checks whether the device is currently able to reach the internet.
  ///
  /// On Web platforms, this always returns [true] as [InternetAddress.lookup]
  /// is not supported. For mobile, it performs a socket lookup with a 5-second timeout.
  static Future<bool> isConnected() async {
    if (kIsWeb) return true;

    try {
      // We look up google.com to verify real-world connectivity.
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      /* print stripped */
      return false;
    } catch (e) {
      /* print stripped */
      return false;
    }
  }

  /// Ensures a network connection is available before proceeding.
  ///
  /// Throws a user-friendly [Exception] if the device is offline.
  /// This should be called before any critical Firebase or API operations.
  static Future<void> requireConnection() async {
    final connected = await isConnected();
    if (!connected) {
      throw Exception(
        'Connection Required: Please check your internet settings and try again.',
      );
    }
  }
}
