import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/helpers/app_snackbar.dart';

class AdminSettingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  var isLoading = false.obs;
  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> fetchSettings() async {
    try {
      isLoading.value = true;
      final doc = await _firestore
          .collection('adminSettings')
          .doc('general')
          .get();
      if (doc.exists) {
        emailController.text = doc.data()?['notificationEmail'] ?? '';
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error fetching admin settings: $e');
    }
  }

  Future<void> saveSettings() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      AppSnackbar.warning(
        'Please enter a notification email address',
        title: 'Required',
      );
      return;
    }

    try {
      isSaving.value = true;
      await _firestore.collection('adminSettings').doc('general').set({
        'notificationEmail': email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      isSaving.value = false;
      AppSnackbar.success('Notification settings saved successfully!');
    } catch (e) {
      isSaving.value = false;
      AppSnackbar.error('Failed to save settings: $e');
    }
  }
}
