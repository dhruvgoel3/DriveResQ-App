import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../services/location_service.dart';

class CreateRequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var locationName = ''.obs;
  var selectedVehicle = ''.obs;
  var imageFile = Rx<File?>(null);

  final landmarkController = TextEditingController();
  final problemController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchLocation();
  }

  // 📍 Auto fetch location
  void fetchLocation() async {
    try {
      locationName.value = await LocationService.getReadableLocation();
    } catch (e) {
      locationName.value = "Location unavailable";
    }
  }

  // 📷 Pick image
  void pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      imageFile.value = File(picked.path);
    }
  }

  // 🚀 Submit Request
  Future<void> submitRequest() async {
    if (landmarkController.text.isEmpty ||
        selectedVehicle.value.isEmpty ||
        problemController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields");
      return;
    }

    isLoading.value = true;

    String? imageUrl;

    if (imageFile.value != null) {
      final ref = FirebaseStorage.instance
          .ref('requests/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(imageFile.value!);
      imageUrl = await ref.getDownloadURL();
    }

    await _firestore.collection('requests').add({
      'driverId': _auth.currentUser!.uid,
      'locationName': locationName.value,
      'landmark': landmarkController.text.trim(),
      'vehicleType': selectedVehicle.value,
      'problem': problemController.text.trim(),
      'description': descriptionController.text.trim(),
      'imageUrl': imageUrl,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });

    isLoading.value = false;
    Get.back();
    Get.snackbar("Success", "Request created successfully");
  }
}
