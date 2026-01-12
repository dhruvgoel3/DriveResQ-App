import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AcceptRequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isAccepting = false.obs;

  Future<void> acceptRequest(String requestId) async {
    isAccepting.value = true;

    final requestRef =
    _firestore.collection('requests').doc(requestId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(requestRef);

        if (!snapshot.exists) {
          throw Exception("Request not found");
        }

        if (snapshot['status'] != 'open') {
          throw Exception("Request already accepted");
        }

        transaction.update(requestRef, {
          'status': 'accepted',
          'mechanicId': _auth.currentUser!.uid,
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      });

      Get.back(); // close detail screen
      Get.snackbar("Success", "Request accepted");

    } catch (e) {
      Get.snackbar("Failed", e.toString());
    } finally {
      isAccepting.value = false;
    }
  }
}
