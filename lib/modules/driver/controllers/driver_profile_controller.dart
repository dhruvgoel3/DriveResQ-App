import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
        Get.snackbar('Error', 'User not logged in');
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
      debugPrint('❌ Error fetching profile: $e');
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
      debugPrint('❌ Stats error: $e');
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
      Get.snackbar(
        'Error',
        'Name cannot be empty',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
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

      Get.snackbar(
        'Success',
        'Profile updated',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Save error: $e');
      Get.snackbar('Error', 'Failed to update profile');
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
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8.w),
              Text('Logout'),
            ],
          ),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text('Yes, Logout'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (confirmed != true) return;

      // Loading
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Container(
              width: 260.w,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Loader Container
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6C63FF).withOpacity(0.1),
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF6C63FF),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    'Logging Out',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Subtitle
                  Text(
                    'Please wait while we securely log you out...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      await Future.delayed(Duration(milliseconds: 500));
      await _auth.signOut();
      Get.back();
      Get.deleteAll(force: true);
      Get.reset();

      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      await Future.delayed(Duration(milliseconds: 500));
      SystemNavigator.pop();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('❌ Logout error: $e');
      Get.snackbar('Error', 'Logout failed. Please try again.');
    }
  }
}
