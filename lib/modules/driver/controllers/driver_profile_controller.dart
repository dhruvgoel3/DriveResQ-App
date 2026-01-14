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
  var userData = Rxn<Map<String, dynamic>>();

  final nameController = TextEditingController();
  var imageFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  // 🔹 Fetch profile
  fetchProfile() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      userData.value = doc.data();
      nameController.text = doc['name'] ?? '';
    }
  }

  // 📷 Pick profile image
  void pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile.value = File(picked.path);
    }
  }

  // 💾 Save profile
  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Name cannot be empty");
      return;
    }

    isLoading.value = true;

    String? photoUrl;

    if (imageFile.value != null) {
      final ref = FirebaseStorage.instance.ref(
        'profiles/${_auth.currentUser!.uid}.jpg',
      );

      await ref.putFile(imageFile.value!);
      photoUrl = await ref.getDownloadURL();
    }

    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'name': nameController.text.trim(),
      if (photoUrl != null) 'photoUrl': photoUrl,
    });

    await fetchProfile();
    isLoading.value = false;

    Get.back();
    Get.snackbar("Success", "Profile updated");
  }

  // 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
