import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
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
    _checkExistingSession();
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
      debugPrint('❌ Admin role check error: $e');
      return false;
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter email and password',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Auto-create admin doc on first login
        await _ensureAdminDoc(credential.user!.uid, email);

        final isAdmin = await _verifyAdminRole(credential.user!.uid);
        if (!isAdmin) {
          await _auth.signOut();
          isLoading.value = false;
          Get.snackbar(
            'Access Denied',
            'You do not have admin privileges',
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red,
          );
          return;
        }

        adminId.value = credential.user!.uid;
        adminEmail.value = email;
        isLoggedIn.value = true;
        isLoading.value = false;

        Get.offAllNamed('/admin/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'No admin account found with this email';
          break;
        case 'wrong-password':
          msg = 'Incorrect password';
          break;
        case 'invalid-email':
          msg = 'Invalid email address';
          break;
        case 'invalid-credential':
          msg = 'Invalid email or password';
          break;
        default:
          msg = e.message ?? 'Login failed';
      }
      Get.snackbar(
        'Login Failed',
        msg,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Login failed: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
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
