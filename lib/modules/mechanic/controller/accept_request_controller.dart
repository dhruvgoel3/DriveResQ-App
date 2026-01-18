import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AcceptRequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isAccepting = false.obs;

  Future<void> acceptRequest(String requestId) async {
    final mechanic = _auth.currentUser;

    // 🔐 SAFETY CHECK
    if (mechanic == null) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    isAccepting.value = true;

    final requestRef = _firestore.collection('requests').doc(requestId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(requestRef);

        if (!snapshot.exists) {
          throw Exception("Request not found");
        }

        final data = snapshot.data() as Map<String, dynamic>;

        if (data['status'] != 'open') {
          throw Exception("Request already accepted");
        }

        // ✅ UPDATE REQUEST WITH MECHANIC DETAILS
        transaction.update(requestRef, {
          'status': 'accepted',
          'mechanicId': mechanic.uid,
          'mechanicPhone': mechanic.phoneNumber ?? '',
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      });

      Get.back(); // close request details screen
      Get.snackbar("Success", "Request accepted successfully");

    } catch (e) {
      Get.snackbar("Failed", e.toString());
    } finally {
      isAccepting.value = false;
    }
  }
}
