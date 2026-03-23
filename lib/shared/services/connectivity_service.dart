import 'dart:io';
import 'package:flutter/foundation.dart';

/// Lightweight connectivity check using DNS lookup.
/// No extra dependencies needed — uses dart:io.
class ConnectivityService {
  /// Returns true if the device can reach the internet.
  static Future<bool> isConnected() async {
    // On web, assume connected (dart:io not available)
    if (kIsWeb) return true;

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
  }

  /// Throws a user-friendly exception if offline.
  /// Call this before critical network operations.
  static Future<void> requireConnection() async {
    if (!await isConnected()) {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    }
  }
}
