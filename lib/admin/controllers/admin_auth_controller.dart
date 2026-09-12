import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/helpers/app_snackbar.dart';

class AdminAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var isFirstSetup = false.obs;
  var adminName = ''.obs;
  var adminEmail = ''.obs;
  var adminId = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var rememberMe = false.obs;
  var obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkFirstSetup();
    _checkExistingSession();
  }

  Future<void> _checkFirstSetup() async {
    try {
      final query = await _firestore.collection('adminUsers').limit(1).get();
      if (query.docs.isEmpty) {
        isFirstSetup.value = true;
      }
    } catch (e) {
      debugPrint('AdminAuthController._checkFirstSetup failed: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> _checkExistingSession() async {
    final user = _auth.currentUser;
    if (user != null) {
      final isAdmin = await _verifyAdminRole(user.uid);
      if (isAdmin) {
        adminId.value = user.uid;
        adminEmail.value = user.email ?? '';
        isLoggedIn.value = true;
      }
    }
  }

  Future<bool> _verifyAdminRole(String uid) async {
    try {
      final doc = await _firestore.collection('adminUsers').doc(uid).get();
      if (doc.exists) {
        adminName.value = doc.data()?['name'] ?? 'Admin';
        return true;
      }
      // Also check by email
      final query = await _firestore
          .collection('adminUsers')
          .where('email', isEqualTo: _auth.currentUser?.email)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        adminName.value = query.docs.first.data()['name'] ?? 'Admin';
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.error('Please enter email and password');
      return;
    }

    try {
      isLoading.value = true;

      if (isFirstSetup.value) {
        // First time setup - register the first admin
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (credential.user != null) {
          await _ensureAdminDoc(credential.user!.uid, email);
          adminId.value = credential.user!.uid;
          adminEmail.value = email;
          isFirstSetup.value = false;
          isLoggedIn.value = true;
          isLoading.value = false;

          AppSnackbar.success(
            'Admin account created successfully!',
            title: 'Setup Complete',
          );
          Get.offAllNamed('/admin/dashboard');
          return;
        }
      } else {
        // Normal Login
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user != null) {
          await _ensureAdminDoc(credential.user!.uid, email);

          final isAdmin = await _verifyAdminRole(credential.user!.uid);
          if (!isAdmin) {
            await _auth.signOut();
            isLoading.value = false;
            AppSnackbar.error(
              'You do not have admin privileges',
              title: 'Access Denied',
            );
            return;
          }

          adminId.value = credential.user!.uid;
          adminEmail.value = email;
          isLoggedIn.value = true;
          isLoading.value = false;

          Get.offAllNamed('/admin/dashboard');
          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String msg = e.message ?? 'Authentication failed';
      if (e.code == 'invalid-email') msg = 'Invalid email address';
      if (e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        msg = 'Invalid email or password';
      }
      if (e.code == 'email-already-in-use') {
        msg = 'This email is already taken. Try signing in.';
      }

      AppSnackbar.error(msg);
    } catch (e) {
      isLoading.value = false;
      AppSnackbar.error('Action failed: $e');
    }
  }

  Future<void> _ensureAdminDoc(String uid, String email) async {
    final doc = await _firestore.collection('adminUsers').doc(uid).get();
    if (!doc.exists) {
      await _firestore.collection('adminUsers').doc(uid).set({
        'email': email,
        'name': 'Admin',
        'role': 'super_admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      AppSnackbar.warning(
        'Please enter your admin email first to reset your password.',
        title: 'Required',
      );
      return;
    }

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      isLoading.value = false;
      AppSnackbar.success(
        'Password reset email sent. Please check your inbox.',
      );
    } catch (e) {
      isLoading.value = false;
      AppSnackbar.error('Failed to send password reset email: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    isLoggedIn.value = false;
    adminId.value = '';
    adminEmail.value = '';
    adminName.value = '';
    emailController.clear();
    passwordController.clear();
    Get.offAllNamed('/admin');
  }
}
