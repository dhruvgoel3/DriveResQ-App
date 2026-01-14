import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_pages.dart';
class DriverProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var isEditMode = false.obs;

  var userData = Rxn<Map<String, dynamic>>();

  // Text controllers
  final nameController = TextEditingController();
  final vehicleTypeController = TextEditingController();
  final plateNumberController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  // 🔹 Fetch profile
  Future<void> fetchProfile() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      userData.value = data;

      nameController.text = data['name'] ?? '';
      vehicleTypeController.text = data['vehicleType'] ?? '';
      plateNumberController.text = data['plateNumber'] ?? '';
    }
  }

  // ✏️ Toggle edit mode
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  // 💾 Save basic info
  Future<void> saveBasicInfo() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Name cannot be empty");
      return;
    }

    isLoading.value = true;

    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'name': nameController.text.trim(),
      'vehicleType': vehicleTypeController.text.trim(),
      'plateNumber': plateNumberController.text.trim(),
    });

    await fetchProfile();

    isLoading.value = false;
    isEditMode.value = false;

    Get.snackbar("Success", "Profile updated");
  }

  // 🚪 Logout (SAFE)
  Future<void> logout() async {
    await _auth.signOut();
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.LOGIN);
  }
}

