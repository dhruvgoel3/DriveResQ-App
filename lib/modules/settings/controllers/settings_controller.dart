import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';

class SettingsController extends GetxController {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  var isLoading = true.obs;

  var settings = <String, bool>{
    'all_notifications': true,
    'new_requests': true,
    'job_updates': true,
    'chat_messages': true,
    'payments': true,
    'promotions': true,
    'sound_enabled': true,
    'vibration_enabled': true,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    if (uid == null) {
      isLoading.value = false;
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      if (data.containsKey('notificationSettings')) {
        final savedPrefs = data['notificationSettings'] as Map<String, dynamic>;
        savedPrefs.forEach((key, value) {
          if (settings.containsKey(key)) {
            settings[key] = value == true;
          }
        });
      }
    } catch (e) {
      debugPrint('SettingsController.loadSettings failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSetting(String key, bool value) async {
    if (uid == null) return;

    // Optimistic update
    final previousValue = settings[key];
    settings[key] = value;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'notificationSettings': {key: value},
      }, SetOptions(merge: true));
    } catch (e) {
      if (previousValue != null) {
          settings[key] = previousValue;
      }
      AppSnackbar.error('Could not update settings');
    }
  }
}
