import 'package:iconsax/iconsax.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class MechanicOnboardingController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // ── Step Tracking ──
  var currentStep = 1.obs;
  var isLoading = false.obs;
  var uploadProgress = 0.0.obs;

  // ── Step 1: Personal Details ──
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  var profilePhoto = Rxn<File>();
  var dob = Rxn<DateTime>();
  var gender = ''.obs;

  // ── Step 2: Professional Details ──
  final shopNameController = TextEditingController();
  final shopAddressController = TextEditingController();
  final experienceController = TextEditingController();
  var shopPhoto = Rxn<File>();
  var specializations = <String>[].obs;
  var servicesOffered = <String>[].obs;

  static List<String> allSpecializations = [
    'Engine Repair',
    'Electrical',
    'Tires',
    'Body Work',
    'AC Service',
    'Battery',
    'Brake Service',
    'Oil Change',
    'General Repair',
  ];

  static List<String> allServices = [
    'Roadside Assistance',
    'Towing Service',
    'Jump Start',
    'Flat Tire Change',
    'Fuel Delivery',
    'Lockout Service',
    'Battery Replacement',
    'Minor Repairs',
    'Emergency Towing',
    'Vehicle Inspection',
  ];

  // ── Step 3: Documents ──
  var aadhaarFront = Rxn<File>();
  var aadhaarBack = Rxn<File>();
  final aadhaarNumberController = TextEditingController();
  var panCard = Rxn<File>();
  var tradeLicense = Rxn<File>();

  // ── Step 4: Bank Details ──
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final confirmAccountController = TextEditingController();
  final ifscController = TextEditingController();
  final bankNameController = TextEditingController();
  final upiController = TextEditingController();

  // ── Step 5: Availability & Pricing ──
  var availableDays = <String>[].obs;
  var serviceRadius = 15.0.obs;
  final baseChargeController = TextEditingController();
  final perKmChargeController = TextEditingController();
  final emergencySurchargeController = TextEditingController();
  var workingHoursStart = TimeOfDay(hour: 9, minute: 0).obs;
  var workingHoursEnd = TimeOfDay(hour: 18, minute: 0).obs;

  static List<String> allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // ── Step 6: Terms ──
  var agreeTerms = false.obs;
  var agreeVerification = false.obs;
  var agreePrivacy = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    shopNameController.dispose();
    shopAddressController.dispose();
    experienceController.dispose();
    aadhaarNumberController.dispose();
    accountHolderController.dispose();
    accountNumberController.dispose();
    confirmAccountController.dispose();
    ifscController.dispose();
    bankNameController.dispose();
    upiController.dispose();
    baseChargeController.dispose();
    perKmChargeController.dispose();
    emergencySurchargeController.dispose();
    super.onClose();
  }

  // ── Navigation ──
  void nextStep() {
    final error = _validateCurrentStep();
    if (error != null) {
      Get.snackbar(
        "Required",
        error,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.w),
      );
      return;
    }
    if (currentStep.value < 6) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  // ── Validation ──
  String? _validateCurrentStep() {
    switch (currentStep.value) {
      case 1:
        if (nameController.text.trim().isEmpty) {
          return 'Please enter your full name';
        }
        if (dob.value == null) return 'Please select your date of birth';
        if (gender.value.isEmpty) return 'Please select your gender';
        return null;
      case 2:
        if (shopNameController.text.trim().isEmpty) {
          return 'Please enter shop/garage name';
        }
        if (shopAddressController.text.trim().isEmpty) {
          return 'Please enter shop address';
        }
        if (shopPhoto.value == null) return 'Please add a shop photo';
        if (experienceController.text.trim().isEmpty) {
          return 'Please enter years of experience';
        }
        if (specializations.isEmpty) {
          return 'Please select at least one specialization';
        }
        return null;
      case 3:
        if (aadhaarFront.value == null) {
          return 'Please upload Aadhaar card front';
        }
        if (aadhaarBack.value == null) return 'Please upload Aadhaar card back';
        if (aadhaarNumberController.text.trim().length != 12) {
          return 'Please enter valid 12-digit Aadhaar number';
        }
        return null;
      case 4:
        if (accountHolderController.text.trim().isEmpty) {
          return 'Please enter account holder name';
        }
        if (accountNumberController.text.trim().isEmpty) {
          return 'Please enter account number';
        }
        if (confirmAccountController.text.trim() !=
            accountNumberController.text.trim()) {
          return 'Account numbers do not match';
        }
        if (ifscController.text.trim().isEmpty) return 'Please enter IFSC code';
        if (!RegExp(
          r'^[A-Z]{4}0[A-Z0-9]{6}$',
        ).hasMatch(ifscController.text.trim().toUpperCase())) {
          return 'Please enter a valid IFSC code (e.g., SBIN0001234)';
        }
        if (bankNameController.text.trim().isEmpty) {
          return 'Please enter bank name';
        }
        return null;
      case 5:
        if (availableDays.isEmpty) {
          return 'Please select at least one working day';
        }
        if (baseChargeController.text.trim().isEmpty) {
          return 'Please enter base service charge';
        }
        if (perKmChargeController.text.trim().isEmpty) {
          return 'Please enter per km charge';
        }
        return null;
      case 6:
        if (!agreeTerms.value) return 'Please agree to terms and conditions';
        if (!agreeVerification.value) {
          return 'Please consent to background verification';
        }
        if (!agreePrivacy.value) return 'Please accept the privacy policy';
        return null;
      default:
        return null;
    }
  }

  // ── Image Picking ──
  Future<void> pickImage(Rxn<File> target, {ImageSource? source}) async {
    if (source != null) {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1200.w,
      );
      if (picked != null) {
        target.value = File(picked.path);
      }
    } else {
      // Show bottom sheet to choose camera or gallery
      Get.bottomSheet(
        SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Wrap(
              children: [
                SizedBox(height: 12.h, width: double.infinity),
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Iconsax.camera, color: Color(0xFFFF9800)),
                  title: Text('Take Photo', style: GoogleFonts.poppins(color: Colors.black87)),
                  onTap: () async {
                    Get.back();
                    final picked = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 75,
                      maxWidth: 1200.w,
                    );
                    if (picked != null) target.value = File(picked.path);
                  },
                ),
                ListTile(
                  leading: Icon(Iconsax.gallery, color: Color(0xFFFF9800)),
                  title: Text('Choose from Gallery', style: GoogleFonts.poppins(color: Colors.black87)),
                  onTap: () async {
                    Get.back();
                    final picked = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 75,
                      maxWidth: 1200.w,
                    );
                    if (picked != null) target.value = File(picked.path);
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ── Toggle Selections ──
  void toggleSpecialization(String item) {
    if (specializations.contains(item)) {
      specializations.remove(item);
    } else {
      specializations.add(item);
    }
  }

  void toggleService(String item) {
    if (servicesOffered.contains(item)) {
      servicesOffered.remove(item);
    } else {
      servicesOffered.add(item);
    }
  }

  void toggleDay(String day) {
    if (availableDays.contains(day)) {
      availableDays.remove(day);
    } else {
      availableDays.add(day);
    }
  }

  // ── Date/Time Pickers ──
  Future<void> pickDob(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dob.value ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFFFF9800)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) dob.value = picked;
  }

  Future<void> pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: workingHoursStart.value,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFFFF9800)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) workingHoursStart.value = picked;
  }

  Future<void> pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: workingHoursEnd.value,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFFFF9800)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) workingHoursEnd.value = picked;
  }

  // ── Firebase Upload ──
  Future<String?> _uploadImage(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((event) {
        uploadProgress.value =
            event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
      });

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('❌ Upload error for $path: $e');
      return null;
    }
  }

  // ── Submit Onboarding ──
  Future<void> submitOnboarding() async {
    final error = _validateCurrentStep();
    if (error != null) {
      Get.snackbar(
        "Required",
        error,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange.shade800,
      );
      return;
    }

    try {
      isLoading.value = true;
      uploadProgress.value = 0;

      final uid = _auth.currentUser!.uid;
      final basePath = 'mechanics/$uid/documents';

      // Upload images
      String? profilePhotoUrl;
      if (profilePhoto.value != null) {
        profilePhotoUrl = await _uploadImage(
          profilePhoto.value!,
          '$basePath/profile.jpg',
        );
      }

      final shopPhotoUrl = await _uploadImage(
        shopPhoto.value!,
        '$basePath/shop.jpg',
      );

      final aadhaarFrontUrl = await _uploadImage(
        aadhaarFront.value!,
        '$basePath/aadhaar_front.jpg',
      );
      final aadhaarBackUrl = await _uploadImage(
        aadhaarBack.value!,
        '$basePath/aadhaar_back.jpg',
      );

      String? panCardUrl;
      if (panCard.value != null) {
        panCardUrl = await _uploadImage(panCard.value!, '$basePath/pan.jpg');
      }

      String? tradeLicenseUrl;
      if (tradeLicense.value != null) {
        tradeLicenseUrl = await _uploadImage(
          tradeLicense.value!,
          '$basePath/trade_license.jpg',
        );
      }

      // Store aadhaar number with only last 4 visible
      final aadhaarRaw = aadhaarNumberController.text.trim();
      final aadhaarMasked = 'XXXX-XXXX-${aadhaarRaw.substring(8)}';

      // Build working hours map
      final hours = {
        'start':
            '${workingHoursStart.value.hour}:${workingHoursStart.value.minute.toString().padLeft(2, '0')}',
        'end':
            '${workingHoursEnd.value.hour}:${workingHoursEnd.value.minute.toString().padLeft(2, '0')}',
      };

      // Save all data to Firestore
      await _firestore.collection('users').doc(uid).update({
        // Step 1
        'fullName': nameController.text.trim(),
        'profilePhotoUrl': profilePhotoUrl ?? '',
        'dob': dob.value?.toIso8601String() ?? '',
        'gender': gender.value,
        'email': emailController.text.trim(),

        // Step 2
        'shopName': shopNameController.text.trim(),
        'shopAddress': shopAddressController.text.trim(),
        'shopPhotoUrl': shopPhotoUrl ?? '',
        'experience': int.tryParse(experienceController.text.trim()) ?? 0,
        'specializations': specializations.toList(),
        'servicesOffered': servicesOffered.toList(),

        // Step 3
        'aadhaarFrontUrl': aadhaarFrontUrl ?? '',
        'aadhaarBackUrl': aadhaarBackUrl ?? '',
        'aadhaarNumber': aadhaarMasked,
        'panCardUrl': panCardUrl ?? '',
        'tradeLicenseUrl': tradeLicenseUrl ?? '',

        // Step 4
        'bankAccountHolder': accountHolderController.text.trim(),
        'bankAccountNumber': accountNumberController.text.trim(),
        'bankIfsc': ifscController.text.trim().toUpperCase(),
        'bankName': bankNameController.text.trim(),
        'upiId': upiController.text.trim(),

        // Step 5
        'workingHours': hours,
        'availableDays': availableDays.toList(),
        'serviceRadius': serviceRadius.value,
        'baseCharge': double.tryParse(baseChargeController.text.trim()) ?? 0,
        'perKmCharge': double.tryParse(perKmChargeController.text.trim()) ?? 0,
        'emergencySurcharge':
            double.tryParse(emergencySurchargeController.text.trim()) ?? 0,

        // Status
        'onboardingCompleted': true,
        'verificationStatus': 'pending',
        'onboardingSubmittedAt': FieldValue.serverTimestamp(),
      });

      // ── Trigger Email to Admin ──
      try {
        final settingsDoc = await _firestore.collection('adminSettings').doc('general').get();
        if (settingsDoc.exists) {
          final adminEmail = settingsDoc.data()?['notificationEmail'] as String?;
          if (adminEmail != null && adminEmail.isNotEmpty) {
            await _firestore.collection('mail').add({
              'to': adminEmail,
              'message': {
                'subject': 'New Mechanic Registration Pending Approval',
                'html': '''
                  <h2>New Mechanic Needs Approval</h2>
                  <p>A new mechanic <b>${nameController.text.trim()}</b> has completed onboarding and is waiting for your review.</p>
                  <p><b>Shop name:</b> ${shopNameController.text.trim()}</p>
                  <br/>
                  <p>Please log in to the admin dashboard to review their documents and approve them.</p>
                  <p><a href="https://driveresq-admin.vercel.app/admin" style="padding: 10px 20px; background-color: #FF9800; color: white; text-decoration: none; border-radius: 5px;">Go to Admin Dashboard</a></p>
                ''',
              },
              'createdAt': FieldValue.serverTimestamp(),
            });
            debugPrint('✅ Triggered admin email notification to $adminEmail');
          }
        }
      } catch (mailError) {
        debugPrint('⚠️ Failed to trigger admin email: $mailError');
        // Do not block onboarding on email failure
      }

      isLoading.value = false;

      Get.offAllNamed('/mechanic-verification');
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Onboarding submit error: $e');
      Get.snackbar(
        "Error",
        "Failed to submit. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
