import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MechanicProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var isEditMode = false.obs;

  var userData = Rxn<Map<String, dynamic>>();

  // Text controllers
  final nameController = TextEditingController();
  final shopNameController = TextEditingController();
  final experienceController = TextEditingController();
  final specialtyController = TextEditingController();

  // Statistics
  var totalJobsCompleted = 0.obs;
  var activeJobs = 0.obs;
  var rating = 0.0.obs;

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
    experienceController.dispose();
    specialtyController.dispose();
    super.onClose();
  }

  // 🔹 Fetch profile
  Future<void> fetchProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        userData.value = {
          ...data,
          'phone': _auth.currentUser?.phoneNumber ?? '',
        };

        nameController.text = data['name'] ?? '';
        shopNameController.text = data['shopName'] ?? '';
        experienceController.text = data['experience'] ?? '';
        specialtyController.text = data['specialty'] ?? '';
      } else {
        // Create basic profile if doesn't exist
        await _createBasicProfile(uid);
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
      Get.snackbar("Error", "Failed to load profile");
    }
  }

  // 📝 Create basic profile
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

  // 📊 Fetch statistics
  Future<void> fetchStatistics() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      // Get completed jobs count
      final completedSnapshot = await _firestore
          .collection('requests')
          .where('mechanicId', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .get();

      totalJobsCompleted.value = completedSnapshot.docs.length;

      // Get active jobs count
      final activeSnapshot = await _firestore
          .collection('requests')
          .where('mechanicId', isEqualTo: uid)
          .where('status', isEqualTo: 'accepted')
          .get();

      activeJobs.value = activeSnapshot.docs.length;

      // Calculate rating (example - you can customize this)
      if (totalJobsCompleted.value > 0) {
        rating.value = 4.5; // Placeholder - implement your rating system
      }
    } catch (e) {
      print("❌ Error fetching statistics: $e");
    }
  }

  // ✏️ Toggle edit mode
  void toggleEditMode() {
    if (isEditMode.value) {
      // Canceling edit - reset fields
      final data = userData.value;
      if (data != null) {
        nameController.text = data['name'] ?? '';
        shopNameController.text = data['shopName'] ?? '';
        experienceController.text = data['experience'] ?? '';
        specialtyController.text = data['specialty'] ?? '';
      }
    }
    isEditMode.value = !isEditMode.value;
  }

  // 💾 Save profile info
  Future<void> saveProfileInfo() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Name cannot be empty",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;

      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        'shopName': shopNameController.text.trim(),
        'experience': experienceController.text.trim(),
        'specialty': specialtyController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await fetchProfile();

      isLoading.value = false;
      isEditMode.value = false;

      Get.snackbar(
        "Success",
        "Profile updated successfully",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      isLoading.value = false;
      print("❌ Error saving profile: $e");
      Get.snackbar(
        "Error",
        "Failed to update profile",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // 🚪 Logout
  Future<void> logout() async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: Get.context!,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text("Logout"),
            ],
          ),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Logout"),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  SizedBox(height: 16),
                  Text("Logging out..."),
                ],
              ),
            ),
          ),
        ),
      );

      await Future.delayed(Duration(milliseconds: 500));

      // Sign out
      await _auth.signOut();

      // Close loading
      Navigator.pop(Get.context!);

      // Clear everything
      Get.deleteAll(force: true);
      Get.reset();

      // Show success
      Get.snackbar(
        "Success",
        "Logged out successfully",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      await Future.delayed(Duration(milliseconds: 500));

      // Close app (user can reopen and see login)
      SystemNavigator.pop();
    } catch (e) {
      if (Navigator.canPop(Get.context!)) {
        Navigator.pop(Get.context!);
      }

      print("❌ Logout error: $e");
      Get.snackbar(
        "Error",
        "Logout failed. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}