import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../services/location_service.dart';
import '../../notifications/services/notification_sender.dart';
import '../../../shared/services/connectivity_service.dart';
import '../../../shared/services/error_handler.dart';
import '../../../utils/helpers/app_snackbar.dart';
import '../../../utils/helpers/app_dialogs.dart';

class CreateRequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var locationName = ''.obs;
  var selectedVehicle = ''.obs;
  var imageFile = Rx<File?>(null);

  // 🔥 Store coordinates
  double? driverLat;
  double? driverLng;

  final landmarkController = TextEditingController();
  final problemController = TextEditingController();
  final descriptionController = TextEditingController();
  final vehicleNumberController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchLocation();
  }

  // 📍 Auto fetch location (NAME + LAT/LNG)
  void fetchLocation() async {
    try {
      locationName.value = "Fetching location...";
      final locationData = await LocationService.getLocationData();

      locationName.value = locationData['locationName'];
      driverLat = locationData['lat'];
      driverLng = locationData['lng'];
    } catch (e) {
      locationName.value = "Enable location to continue";
    }
  }

  // ✏️ Edit location manually
  void editLocationName() async {
    final result = await AppDialogs.input(
      title: 'Edit Location',
      hint: 'Enter location manually',
      initialValue: locationName.value,
    );

    if (result != null && result.isNotEmpty) {
      locationName.value = result;
    }
  }

  // 📷 Pick image
  void pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      imageFile.value = File(picked.path);
    }
  }

  // 🚀 Submit Request
  Future<void> submitRequest() async {
    if (landmarkController.text.isEmpty ||
        selectedVehicle.value.isEmpty ||
        problemController.text.isEmpty ||
        driverLat == null ||
        driverLng == null) {
      AppSnackbar.warning('Please fill all required fields');
      return;
    }

    isLoading.value = true;

    try {
      // Check network before making any Firebase calls
      await ConnectivityService.requireConnection();

      String? imageUrl;

      // 📤 Upload image if exists
      if (imageFile.value != null) {
        final ref = FirebaseStorage.instance.ref(
          'requests/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        await ref.putFile(imageFile.value!);
        imageUrl = await ref.getDownloadURL();
      }

      // 1️⃣ FETCH DRIVER DETAILS FOR CHAT display
      String driverName = 'Driver';
      String driverPhoto = '';
      try {
        final doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          driverName = data['fullName'] ?? data['name'] ?? 'Driver';
          driverPhoto = data['profilePhotoUrl'] ?? data['photoUrl'] ?? '';
        }
      } catch (e) {
        /* print stripped */
      }

      // 🧠 SAVE REQUEST (WITH COORDINATES)
      final requestRef = await _firestore.collection('requests').add({
        'driverId': _auth.currentUser!.uid,
        'driverName': driverName,
        'driverPhoto': driverPhoto,
        'driverPhone': _auth.currentUser!.phoneNumber,
        'status': 'open',
        'problem': problemController.text.trim(),
        'vehicleType': selectedVehicle.value,
        'locationName': locationName.value,
        'landmark': landmarkController.text.trim(),
        'description': descriptionController.text.trim(),
        'driverLat': driverLat,
        'driverLng': driverLng,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'vehicleNumber': vehicleNumberController.text.trim(),
      });

      // 🔔 Send notification to nearby mechanics
      await NotificationSender.notifyNearbyMechanics(
        requestId: requestRef.id,
        driverId: _auth.currentUser!.uid,
        driverLat: driverLat!,
        driverLng: driverLng!,
        problem: problemController.text.trim(),
        location: locationName.value,
      );

      isLoading.value = false;
      Get.back();
      AppSnackbar.success('Request created successfully!');
    } on Exception catch (e) {
      isLoading.value = false;
      ErrorHandler.handle(e, onRetry: submitRequest);
    }
  }

  @override
  void onClose() {
    landmarkController.dispose();
    problemController.dispose();
    descriptionController.dispose();
    vehicleNumberController.dispose();
    super.onClose();
  }
}
