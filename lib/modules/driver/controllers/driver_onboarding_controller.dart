import 'package:iconsax/iconsax.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';

class DriverOnboardingController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  // Step management
  var currentStep = 0.obs;
  var isLoading = false.obs;

  // Step 1: Personal Details
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  var gender = ''.obs;
  var dob = Rxn<DateTime>();

  // Step 2: Govt ID
  var selectedIdType = 'Aadhaar Card'.obs;
  final idNumberController = TextEditingController();
  var idFrontPath = ''.obs;
  var idBackPath = ''.obs;

  final idTypes = ['Aadhaar Card', 'PAN Card', 'Driving License', 'Voter ID'];

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    idNumberController.dispose();
    super.onClose();
  }

  void nextStep() {
    final error = _validateCurrentStep();
    if (error != null) {
      AppSnackbar.warning(error, title: 'Required');
      return;
    }
    if (currentStep.value < 1) {
      currentStep.value++;
    } else {
      submitOnboarding();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  String? _validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        if (nameController.text.trim().isEmpty) return 'Please enter your name';
        if (addressController.text.trim().isEmpty) {
          return 'Please enter your address';
        }
        if (gender.value.isEmpty) return 'Please select gender';
        return null;
      case 1:
        if (idNumberController.text.trim().isEmpty) {
          return 'Please enter ID number';
        }
        if (idFrontPath.value.isEmpty) return 'Please upload front of your ID';
        return null;
      default:
        return null;
    }
  }

  Future<void> pickIdPhoto({required bool isFront}) async {
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Upload Photo',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                radius: 20.r,
                child: Icon(
                  Iconsax.camera,
                  color: const Color(0xFF6C63FF),
                  size: 20.w,
                ),
              ),
              title: Text(
                'Take a Photo',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                radius: 20.r,
                child: Icon(
                  Iconsax.gallery,
                  color: const Color(0xFF6C63FF),
                  size: 20.w,
                ),
              ),
              title: Text(
                'Choose from Gallery',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked == null) return;

    if (isFront) {
      idFrontPath.value = picked.path;
    } else {
      idBackPath.value = picked.path;
    }
  }

  Future<void> pickDob(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) dob.value = picked;
  }

  // ── Firebase Upload ──
  Future<String?> _uploadImage(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint(' Upload error for $path: $e');
      return null;
    }
  }

  Future<void> submitOnboarding() async {
    final error = _validateCurrentStep();
    if (error != null) {
      AppSnackbar.warning(error, title: 'Required');
      return;
    }

    try {
      isLoading.value = true;
      final uid = _auth.currentUser!.uid;

      // Mask ID number (show only last 4)
      final rawId = idNumberController.text.trim();
      final maskedId = rawId.length > 4
          ? '${'X' * (rawId.length - 4)}${rawId.substring(rawId.length - 4)}'
          : rawId;

      // Upload images
      String? idFrontUrl;
      String? idBackUrl;

      if (idFrontPath.value.isNotEmpty) {
        idFrontUrl = await _uploadImage(
          File(idFrontPath.value),
          'drivers/$uid/documents/id_front.jpg',
        );
      }

      if (idBackPath.value.isNotEmpty) {
        idBackUrl = await _uploadImage(
          File(idBackPath.value),
          'drivers/$uid/documents/id_back.jpg',
        );
      }

      await _firestore.collection('users').doc(uid).update({
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'gender': gender.value,
        'dob': dob.value?.toIso8601String() ?? '',
        'govtIdType': selectedIdType.value,
        'govtIdNumber': maskedId,
        'idFrontUrl': idFrontUrl ?? '',
        'idBackUrl': idBackUrl ?? '',
        'verificationStatus': 'pending',
        'driverOnboardingCompleted': true,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
      });

      isLoading.value = false;
      Get.offAllNamed('/driver');
      AppSnackbar.success('Profile setup complete 🎉', title: 'Welcome!');
    } catch (e) {
      isLoading.value = false;
      debugPrint(' Driver onboarding error: $e');
      AppSnackbar.error('Failed to submit. Please try again.');
    }
  }
}
