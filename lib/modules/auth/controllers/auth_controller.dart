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

  /// Sanitize the raw phone input: strip country code prefix, spaces, dashes,
  /// and leading zeros so we always end up with the bare 10-digit number.
  String _sanitizePhone(String raw) {
    // Remove spaces, dashes, parentheses
    String cleaned = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Strip leading '+91' or '91' country-code prefix if user typed it
    if (cleaned.startsWith('+91')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('91') && cleaned.length > 10) {
      cleaned = cleaned.substring(2);
    }

    // Strip leading zero (some people type 0XXXXXXXXXX)
    if (cleaned.startsWith('0') && cleaned.length == 11) {
      cleaned = cleaned.substring(1);
    }

    return cleaned;
  }

  // Send OTP
  Future<void> sendOTP() async {
    final sanitized = _sanitizePhone(phoneController.text);

    if (sanitized.length != 10 || !RegExp(r'^\d{10}$').hasMatch(sanitized)) {
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

      final phone = '+91$sanitized';
      debugPrint("📞 Sending OTP to: $phone");

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint("✅ Auto-verification completed");
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          debugPrint("❌ Verification failed: ${e.code} - ${e.message}");
          String errorMsg;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMsg =
                  'The phone number format is invalid. Please enter a valid 10-digit Indian number.';
              break;
            case 'too-many-requests':
              errorMsg =
                  'Too many requests. Please wait a moment and try again.';
              break;
            case 'quota-exceeded':
              errorMsg = 'SMS quota exceeded. Please try again later.';
              break;
            default:
              errorMsg = e.message ?? "Verification failed. Please try again.";
          }
          Get.snackbar(
            "Error",
            errorMsg,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        },
        codeSent: (String verId, int? resendToken) {
          isLoading.value = false;
          verificationId = verId;
          debugPrint("📨 OTP code sent, verificationId: $verId");

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
      debugPrint("❌ Exception in sendOTP: $e");
      Get.snackbar(
        "Error",
        "Failed to send OTP. Please check your internet connection and try again.",
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

      debugPrint(
        "🔐 Verifying OTP: ${otpController.text.trim()} with verificationId: $verificationId",
      );

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text.trim(),
      );

      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      debugPrint(
        "❌ OTP verification FirebaseAuthException: ${e.code} - ${e.message}",
      );
      String errorMsg;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMsg =
              'The OTP you entered is incorrect. Please check and try again.';
          break;
        case 'session-expired':
          errorMsg = 'The OTP has expired. Please request a new one.';
          break;
        case 'invalid-verification-id':
          errorMsg =
              'Verification session expired. Please go back and resend OTP.';
          break;
        default:
          errorMsg = e.message ?? 'Verification failed. Please try again.';
      }
      Get.snackbar(
        "Error",
        errorMsg,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      isLoading.value = false;
      debugPrint("❌ OTP verification error: $e");
      Get.snackbar(
        "Error",
        "Verification failed: $e",
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
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

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
      final data = userDoc.data();
      final role = data?['role'];

      if (role == 'driver') {
        Get.offAllNamed(Routes.DRIVER);
      } else if (role == 'mechanic') {
        // Check mechanic onboarding status
        final onboardingCompleted = data?['onboardingCompleted'] == true;
        final verificationStatus = data?['verificationStatus'] ?? '';

        if (!onboardingCompleted) {
          Get.offAllNamed(Routes.MECHANIC_ONBOARDING);
        } else if (verificationStatus == 'pending' ||
            verificationStatus == 'rejected') {
          Get.offAllNamed(Routes.MECHANIC_VERIFICATION);
        } else if (verificationStatus == 'approved') {
          Get.offAllNamed(Routes.MECHANIC);
        } else {
          Get.offAllNamed(Routes.MECHANIC_ONBOARDING);
        }
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
