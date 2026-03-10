import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../services/location_service.dart';
import '../../notifications/services/notification_sender.dart';

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

  @override
  void onInit() {
    super.onInit();
    fetchLocation();
  }

  // 📍 Auto fetch location (NAME + LAT/LNG)
  void fetchLocation() async {
    try {
      locationName.value = "Fetching location...";
      final locationData = await LocationService.getLocationData(); // ✅ FIXED

      locationName.value = locationData['locationName'];
      driverLat = locationData['lat'];
      driverLng = locationData['lng'];
    } catch (e) {
      locationName.value = "Enable location to continue";
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
      Get.snackbar("Error", "Please fill all required fields");
      return;
    }

    isLoading.value = true;

    String? imageUrl;

    // 📤 Upload image if exists
    if (imageFile.value != null) {
      final ref = FirebaseStorage.instance.ref(
        'requests/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await ref.putFile(imageFile.value!);
      imageUrl = await ref.getDownloadURL();
    }

    // 🧠 SAVE REQUEST (WITH COORDINATES)
    final requestRef = await _firestore.collection('requests').add({
      'driverId': _auth.currentUser!.uid,
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
      'imageUrl': imageUrl, // ✅ ADDED - Store image URL
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
    Get.snackbar("Success", "Request created successfully");
  }

  @override
  void onClose() {
    landmarkController.dispose();
    problemController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
