import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../notifications/services/notification_sender.dart';
import '../../../shared/services/rating_service.dart';
import '../../../utils/helpers/app_snackbar.dart';

class JobCompletionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // Step tracking
  var currentStep = 0.obs;
  static const totalSteps = 3; // Summary → Rating → Success
  var isLoading = false.obs;

  // Job data
  var jobData = Rxn<Map<String, dynamic>>();
  var jobId = ''.obs;

  // Step 1: Job Summary
  var selectedServices = <String>[].obs;
  var partsReplaced = <Map<String, dynamic>>[].obs;
  final laborChargesController = TextEditingController();
  final notesController = TextEditingController();
  var beforePhotos = <File>[].obs;
  var afterPhotos = <File>[].obs;

  // Calculated costs
  var baseCharge = 0.0.obs;
  var laborCharges = 0.0.obs;
  var partsTotal = 0.0.obs;
  var travelCost = 0.0.obs;
  var subtotal = 0.0.obs;
  var gstAmount = 0.0.obs;
  var totalAmount = 0.0.obs;

  // Payment (cash only — settled directly between driver & mechanic)
  var cashCollected = false.obs;

  // Step 3: Rating
  var mechanicRating = 0.0.obs;
  final reviewController = TextEditingController();
  var quickTags = <String>[].obs;

  // Invoice
  var invoiceNumber = ''.obs;

  static List<String> serviceOptions = [
    'Engine Repair',
    'Tire Change',
    'Battery Jump Start',
    'Brake Service',
    'Fuel Delivery',
    'Towing',
    'Oil Change',
    'Coolant Refill',
    'Electrical Repair',
    'Other',
  ];

  static List<String> ratingTags = [
    'Cooperative',
    'Respectful',
    'Paid on time',
    'Good communication',
    'Patient',
    'Clear about problem',
  ];

  @override
  void onClose() {
    laborChargesController.dispose();
    notesController.dispose();
    reviewController.dispose();
    super.onClose();
  }

  void initJob(Map<String, dynamic> job, dynamic id) {
    jobData.value = job;
    jobId.value = (id ?? job['id'] ?? '').toString();
    baseCharge.value = 200; // Default base charge

    // Calculate travel cost from distance
    final dist = job['distance'];
    if (dist != null) {
      travelCost.value = (double.tryParse(dist.toString()) ?? 0) * 15; // ₹15/km
    }

    // Generate invoice number
    final now = DateTime.now();
    invoiceNumber.value =
        'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    _recalculate();
  }

  void toggleService(String service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
  }

  void addPart() {
    partsReplaced.add({
      'name': '',
      'quantity': 1,
      'costPerUnit': 0.0,
      'total': 0.0,
    });
  }

  void updatePart(int index, String field, dynamic value) {
    final part = Map<String, dynamic>.from(partsReplaced[index]);
    part[field] = value;
    if (field == 'quantity' || field == 'costPerUnit') {
      part['total'] =
          (part['quantity'] as int) * (part['costPerUnit'] as double);
    }
    partsReplaced[index] = part;
    _recalculate();
  }

  void removePart(int index) {
    partsReplaced.removeAt(index);
    _recalculate();
  }

  void updateLaborCharges(String value) {
    laborCharges.value = double.tryParse(value) ?? 0;
    _recalculate();
  }

  void _recalculate() {
    partsTotal.value = partsReplaced.fold(
      0.0,
      (sum, p) => sum + (p['total'] as double? ?? 0),
    );
    subtotal.value =
        baseCharge.value +
        laborCharges.value +
        partsTotal.value +
        travelCost.value;
    totalAmount.value = subtotal.value;
  }

  Future<void> pickPhotos(bool isBefore) async {
    final images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      final files = images.map((x) => File(x.path)).toList();
      if (isBefore) {
        beforePhotos.addAll(files);
      } else {
        afterPhotos.addAll(files);
      }
    }
  }

  void removePhoto(bool isBefore, int index) {
    if (isBefore) {
      beforePhotos.removeAt(index);
    } else {
      afterPhotos.removeAt(index);
    }
  }

  bool validateStep1() {
    if (selectedServices.isEmpty) {
      AppSnackbar.warning(
        'Select at least one service performed',
        title: 'Required',
      );
      return false;
    }
    return true;
  }

  void nextStep() {
    if (currentStep.value == 0 && !validateStep1()) return;
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void toggleTag(String tag) {
    if (quickTags.contains(tag)) {
      quickTags.remove(tag);
    } else {
      quickTags.add(tag);
    }
  }

  Future<void> submitCompletion() async {
    try {
      isLoading.value = true;
      final uid = _auth.currentUser!.uid;
      final job = jobData.value!;

      final now = DateTime.now();
      final acceptedAt = job['acceptedAt'];
      DateTime startTime;
      if (acceptedAt is Timestamp) {
        startTime = acceptedAt.toDate();
      } else {
        startTime = now.subtract(const Duration(hours: 1));
      }

      final completionData = {
        'jobId': jobId.value,
        'driverId': job['driverId'] ?? '',
        'mechanicId': uid,
        'driverPhone': job['driverPhone'] ?? '',
        'mechanicPhone': _auth.currentUser?.phoneNumber ?? '',
        'vehicleType': job['vehicleType'] ?? '',
        'problem': job['problem'] ?? '',
        'locationName': job['locationName'] ?? '',
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(now),
        'durationMinutes': now.difference(startTime).inMinutes,
        'servicesPerformed': selectedServices.toList(),
        'partsReplaced': partsReplaced.toList(),
        'laborCharges': laborCharges.value,
        'travelCost': travelCost.value,
        'partsTotal': partsTotal.value,
        'baseCharge': baseCharge.value,
        'subtotal': subtotal.value,
        'totalAmount': totalAmount.value,
        'paymentMethod': 'Cash (settled directly)',
        'cashCollected': cashCollected.value,
        'notes': notesController.text.trim(),
        'driverRating': mechanicRating.value, // Mechanic rates the driver
        'driverReview': reviewController.text.trim(),
        'driverTags': quickTags.toList(),
        'invoiceNumber': invoiceNumber.value,
        'completedAt': FieldValue.serverTimestamp(),
        'status': 'completed',
      };

      // Save to completedJobs
      await _firestore
          .collection('completedJobs')
          .doc(jobId.value)
          .set(completionData);

      // Update request status
      await _firestore.collection('requests').doc(jobId.value).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'totalAmount': totalAmount.value,
        'paymentMethod': 'Cash (settled directly)',
        'invoiceNumber': invoiceNumber.value,
      });

      // Update mechanic earnings
      await _firestore.collection('users').doc(uid).update({
        'totalEarnings': FieldValue.increment(totalAmount.value),
        'totalJobsCompleted': FieldValue.increment(1),
      });

      // Submit Rating for the driver
      if (mechanicRating.value > 0 && job['driverId'] != null) {
        try {
          await RatingService.submitRating(
            targetUserId: job['driverId'],
            newRating: mechanicRating.value,
            reviewerId: uid,
            reviewText: reviewController.text.trim(),
          );
        } catch (e) {
          debugPrint('Failed to submit driver rating: $e');
        }
      }

      // 🔔 Send Push Notification to Driver
      final mechanicDoc = await _firestore.collection('users').doc(uid).get();
      final mechanicName = mechanicDoc.data()?['name'] ?? 'Your Mechanic';

      if ((job['driverId'] ?? '').toString().isNotEmpty) {
        await NotificationSender.notifyDriverJobCompleted(
          requestId: jobId.value,
          driverId: job['driverId'] ?? '',
          mechanicName: mechanicName,
          totalAmount: totalAmount.value,
        );
      }

      isLoading.value = false;
      currentStep.value = 2; // Go to success screen
    } catch (e) {
      isLoading.value = false;
      debugPrint(' Completion error: $e');
      AppSnackbar.error('Failed to complete job: $e');
    }
  }

  String get formattedDuration {
    final job = jobData.value;
    if (job == null) return '—';
    final acceptedAt = job['acceptedAt'];
    if (acceptedAt is Timestamp) {
      final dur = DateTime.now().difference(acceptedAt.toDate());
      final hours = dur.inHours;
      final mins = dur.inMinutes % 60;
      if (hours > 0) return '${hours}h ${mins}m';
      return '${mins}m';
    }
    return '—';
  }
}
