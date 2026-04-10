import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';
import 'package:driveresq_app/utils/helpers/app_dialogs.dart';

class MechanicProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var isEditMode = false.obs;

  var userData = Rxn<Map<String, dynamic>>();

  // Editable text controllers
  final nameController = TextEditingController();
  final shopNameController = TextEditingController();
  final shopAddressController = TextEditingController();
  final experienceController = TextEditingController();
  final emailController = TextEditingController();
  final baseChargeController = TextEditingController();
  final perKmChargeController = TextEditingController();

  // Statistics
  var totalJobsCompleted = 0.obs;
  var activeJobs = 0.obs;
  var rating = 0.0.obs;
  var totalEarnings = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchStatistics();
  }

  @override
  void onClose() {
    nameController.dispose();
    shopNameController.dispose();
    shopAddressController.dispose();
    experienceController.dispose();
    emailController.dispose();
    baseChargeController.dispose();
    perKmChargeController.dispose();
    super.onClose();
  }

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

        // Set editable fields
        nameController.text = data['fullName'] ?? data['name'] ?? '';
        shopNameController.text = data['shopName'] ?? '';
        shopAddressController.text = data['shopAddress'] ?? '';
        experienceController.text = (data['experience'] ?? '').toString();
        emailController.text = data['email'] ?? '';
        baseChargeController.text = (data['baseCharge'] ?? '').toString();
        perKmChargeController.text = (data['perKmCharge'] ?? '').toString();
      } else {
        await _createBasicProfile(uid);
      }
    } catch (e) {
      /* print stripped */
      AppSnackbar.error('Failed to load profile');
    }
  }

  Future<void> _createBasicProfile(String uid) async {
    final basicData = {
      'uid': uid,
      'phone': _auth.currentUser?.phoneNumber ?? '',
      'role': 'mechanic',
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('users').doc(uid).set(basicData);
    userData.value = basicData;
  }

  Future<void> fetchStatistics() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final completedSnapshot = await _firestore
          .collection('requests')
          .where('mechanicId', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .get();
      totalJobsCompleted.value = completedSnapshot.docs.length;

      final activeSnapshot = await _firestore
          .collection('requests')
          .where('mechanicId', isEqualTo: uid)
          .where('status', isEqualTo: 'accepted')
          .get();
      activeJobs.value = activeSnapshot.docs.length;

      // Fetch earnings from completedJobs
      final earningsSnapshot = await _firestore
          .collection('completedJobs')
          .where('mechanicId', isEqualTo: uid)
          .get();
      double total = 0;
      for (var doc in earningsSnapshot.docs) {
        total += (doc.data()['totalAmount'] as num?)?.toDouble() ?? 0;
      }
      totalEarnings.value = total;

      // Fetch average rating from completedJobs
      if (earningsSnapshot.docs.isNotEmpty) {
        double ratingSum = 0;
        int ratingCount = 0;
        for (var doc in earningsSnapshot.docs) {
          final r = (doc.data()['driverRating'] as num?)?.toDouble() ?? 0;
          if (r > 0) {
            ratingSum += r;
            ratingCount++;
          }
        }
        rating.value = ratingCount > 0 ? ratingSum / ratingCount : 0;
      }
    } catch (e) {
      /* print stripped */
    }
  }

  void toggleEditMode() {
    if (isEditMode.value) {
      final data = userData.value;
      if (data != null) {
        nameController.text = data['fullName'] ?? data['name'] ?? '';
        shopNameController.text = data['shopName'] ?? '';
        shopAddressController.text = data['shopAddress'] ?? '';
        experienceController.text = (data['experience'] ?? '').toString();
        emailController.text = data['email'] ?? '';
        baseChargeController.text = (data['baseCharge'] ?? '').toString();
        perKmChargeController.text = (data['perKmCharge'] ?? '').toString();
      }
    }
    isEditMode.value = !isEditMode.value;
  }

  Future<void> saveProfileInfo() async {
    if (nameController.text.trim().isEmpty) {
      AppSnackbar.error('Name cannot be empty');
      return;
    }

    try {
      isLoading.value = true;
      final uid = _auth.currentUser!.uid;

      await _firestore.collection('users').doc(uid).update({
        'fullName': nameController.text.trim(),
        'shopName': shopNameController.text.trim(),
        'shopAddress': shopAddressController.text.trim(),
        'experience': int.tryParse(experienceController.text.trim()) ?? 0,
        'email': emailController.text.trim(),
        'baseCharge': double.tryParse(baseChargeController.text.trim()) ?? 0,
        'perKmCharge': double.tryParse(perKmChargeController.text.trim()) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await fetchProfile();
      isLoading.value = false;
      isEditMode.value = false;

      AppSnackbar.success('Profile updated successfully');
    } catch (e) {
      isLoading.value = false;
      /* print stripped */
      AppSnackbar.error('Failed to update profile');
    }
  }

  // Helper getters
  String get displayName {
    final d = userData.value;
    return d?['fullName'] ?? d?['name'] ?? 'Mechanic';
  }

  String get verificationBadge {
    final status = userData.value?['verificationStatus'] ?? 'pending';
    switch (status) {
      case 'approved':
        return 'VERIFIED MECHANIC';
      case 'pending':
        return 'VERIFICATION PENDING';
      case 'rejected':
        return 'VERIFICATION REJECTED';
      default:
        return 'UNVERIFIED';
    }
  }

  Color get verificationColor {
    final status = userData.value?['verificationStatus'] ?? 'pending';
    switch (status) {
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<String> get specializations {
    final list = userData.value?['specializations'];
    if (list is List) return list.cast<String>();
    return [];
  }

  List<String> get servicesOffered {
    final list = userData.value?['servicesOffered'];
    if (list is List) return list.cast<String>();
    return [];
  }

  List<String> get availableDays {
    final list = userData.value?['availableDays'];
    if (list is List) return list.cast<String>();
    return [];
  }

  String get workingHoursFormatted {
    final hours = userData.value?['workingHours'];
    if (hours is Map) {
      return '${hours['start'] ?? '—'} to ${hours['end'] ?? '—'}';
    }
    return 'Not set';
  }

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
      // This will automatically dispose of controllers associated with those routes.
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
