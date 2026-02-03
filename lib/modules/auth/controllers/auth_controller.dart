import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable states
  var isLoading = false.obs;
  var selectedRole = ''.obs;

  // Phone auth
  String? verificationId;
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // DON'T check auth state here - let splash handle it
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  // Select role
  void selectRole(String role) {
    selectedRole.value = role;
  }

  // Send OTP
  Future<void> sendOTP() async {
    if (phoneController.text.trim().length != 10) {
      Get.snackbar(
        "Error",
        "Please enter a valid 10-digit phone number",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (selectedRole.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select your role first",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;

      final phone = '+91${phoneController.text.trim()}';

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          Get.snackbar(
            "Error",
            e.message ?? "Verification failed",
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        },
        codeSent: (String verId, int? resendToken) {
          isLoading.value = false;
          verificationId = verId;

          Get.snackbar(
            "Success",
            "OTP sent to $phone",
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
          );

          Get.toNamed('/otp');
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Failed to send OTP: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Verify OTP
  Future<void> verifyOTP() async {
    if (otpController.text.trim().length != 6) {
      Get.snackbar(
        "Error",
        "Please enter a valid 6-digit OTP",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (verificationId == null) {
      Get.snackbar(
        "Error",
        "Verification ID not found. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text.trim(),
      );

      await _signInWithCredential(credential);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Invalid OTP. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Sign in with credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _createUserProfile(user);
        } else {
          final existingRole = userDoc.data()?['role'];
          if (existingRole != selectedRole.value) {
            await _firestore.collection('users').doc(user.uid).update({
              'role': selectedRole.value,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        isLoading.value = false;
        await _navigateBasedOnRole(user.uid);
      }
    } catch (e) {
      isLoading.value = false;
      throw e;
    }
  }

  // Create user profile
  Future<void> _createUserProfile(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'phone': user.phoneNumber,
      'role': selectedRole.value,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  // Navigate based on role
  Future<void> _navigateBasedOnRole(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final role = userDoc.data()?['role'];

      if (role == 'driver') {
        Get.offAllNamed(Routes.DRIVER);
      } else if (role == 'mechanic') {
        Get.offAllNamed(Routes.MECHANIC);
      } else {
        Get.offAllNamed(Routes.ROLE);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load user data");
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    otpController.clear();
    await sendOTP();
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    Get.deleteAll(force: true);
    Get.offAllNamed('/role');
  }
}