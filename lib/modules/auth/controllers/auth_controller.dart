import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../app/routes/app_pages.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var verificationId = ''.obs;

  // 🔹 Check user on app start
  @override
  void onReady() {
    super.onReady();
    _checkAuth();
  }

  void _checkAuth() async {
    User? user = _auth.currentUser;
    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      _checkUserRole(user.uid);
    }
  }

  // 🔹 Send OTP
  void sendOtp(String phone) async {
    isLoading.value = true;

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        _postLogin();
      },
      verificationFailed: (e) {
        isLoading.value = false;
        Get.snackbar("Error", e.message ?? "OTP Failed");
      },
      codeSent: (vid, _) {
        verificationId.value = vid;
        isLoading.value = false;
      },
      codeAutoRetrievalTimeout: (vid) {
        verificationId.value = vid;
      },
    );
  }

  // 🔹 Verify OTP
  void verifyOtp(String otp) async {
    isLoading.value = true;

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId.value,
      smsCode: otp,
    );

    await _auth.signInWithCredential(credential);
    _postLogin();
  }

  // 🔹 After login
  void _postLogin() async {
    User user = _auth.currentUser!;
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      _checkUserRole(user.uid);
    } else {
      Get.offAllNamed(Routes.ROLE);
    }
  }

  // 🔹 Save role
  void saveRole(String role) async {
    User user = _auth.currentUser!;
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'phone': user.phoneNumber,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _navigateByRole(role);
  }

  // 🔹 Role based navigation
  void _checkUserRole(String uid) async {
    var doc = await _firestore.collection('users').doc(uid).get();
    String role = doc['role'];
    _navigateByRole(role);
  }

  void _navigateByRole(String role) {
    if (role == 'driver') {
      Get.offAllNamed(Routes.DRIVER);
    } else {
      Get.offAllNamed(Routes.MECHANIC);
    }
  }
}
