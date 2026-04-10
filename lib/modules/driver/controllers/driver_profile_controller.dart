import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/helpers/app_snackbar.dart';
import '../../../utils/helpers/app_dialogs.dart';

class DriverProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var isEditMode = false.obs;

  var userData = Rxn<Map<String, dynamic>>();

  // Stats
  var totalRequests = 0.obs;
  var completedRequests = 0.obs;
  var totalSpent = 0.0.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final genderController = TextEditingController();
  final dobController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchStats();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    genderController.dispose();
    dobController.dispose();
    super.onClose();
  }

  // ─── Fetch profile ───
  Future<void> fetchProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        AppSnackbar.error('User not logged in');
        return;
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        userData.value = {
          ...data,
          'phone': _auth.currentUser?.phoneNumber ?? '',
        };

        nameController.text = data['fullName'] ?? data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        addressController.text = data['address'] ?? '';
        genderController.text = data['gender'] ?? '';
        dobController.text = data['dob'] ?? '';
      }
    } catch (e) {
      /* print stripped */
    }
  }

  // ─── Fetch statistics ───
  Future<void> fetchStats() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final allReqs = await _firestore
          .collection('requests')
          .where('driverId', isEqualTo: uid)
          .get();

      totalRequests.value = allReqs.docs.length;

      int completed = 0;
      double spent = 0;

      for (var doc in allReqs.docs) {
        final data = doc.data();
        if (data['status'] == 'completed') {
          completed++;
          spent += (data['totalAmount'] as num?)?.toDouble() ?? 0;
        }
      }

      completedRequests.value = completed;
      totalSpent.value = spent;
    } catch (e) {
      /* print stripped */
    }
  }

  // ─── Toggle edit mode ───
  void toggleEditMode() {
    if (isEditMode.value) {
      final data = userData.value;
      if (data != null) {
        nameController.text = data['fullName'] ?? data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        addressController.text = data['address'] ?? '';
        genderController.text = data['gender'] ?? '';
        dobController.text = data['dob'] ?? '';
      }
    }
    isEditMode.value = !isEditMode.value;
  }

  // ─── Save profile ───
  Future<void> saveBasicInfo() async {
    if (nameController.text.trim().isEmpty) {
      AppSnackbar.error('Name cannot be empty');
      return;
    }

    try {
      isLoading.value = true;
      final uid = _auth.currentUser!.uid;

      await _firestore.collection('users').doc(uid).update({
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'gender': genderController.text.trim(),
        'dob': dobController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await fetchProfile();
      isLoading.value = false;
      isEditMode.value = false;

      AppSnackbar.success('Profile updated');
    } catch (e) {
      isLoading.value = false;
      /* print stripped */
      AppSnackbar.error('Failed to update profile');
    }
  }

  // Getters
  String get displayName =>
      userData.value?['fullName'] ?? userData.value?['name'] ?? 'Driver';

  String get phone => userData.value?['phone'] ?? '';

  String get email => userData.value?['email'] ?? '';

  String get address => userData.value?['address'] ?? '';

  String get gender => userData.value?['gender'] ?? '';

  String get dob {
    final d = userData.value?['dob'] ?? '';
    if (d.isEmpty) return '';
    try {
      final dt = DateTime.parse(d);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return d;
    }
  }

  String get govtIdType => userData.value?['govtIdType'] ?? '';

  String get govtIdNumber => userData.value?['govtIdNumber'] ?? '';

  bool get isOnboarded => userData.value?['driverOnboardingCompleted'] == true;

  // ─── Logout ───
  Future<void> logout() async {
    try {
      final confirmed = await AppDialogs.confirm(
        title: 'Logout',
        message: 'Are you sure you want to logout?',
        confirmText: 'Yes, Logout',
        cancelText: 'Cancel',
        icon: Iconsax.logout,
        iconColor: Colors.red,
        isDangerous: true,
      );

      if (confirmed != true) return;

      AppDialogs.loading(message: 'Logging out...');

      // 1. Sign out from Firebase
      await _auth.signOut();
      
      // 2. Small delay to ensure Firebase state updates
      await Future.delayed(const Duration(milliseconds: 300));

      // 3. Close the loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // 4. Navigate to role selection and clear all previous routes
      Get.offAllNamed('/role');
      
      AppSnackbar.success('Logged out successfully');
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      /* print stripped */
      AppSnackbar.error('Logout failed: ${e.toString()}');
    }
  }
}
