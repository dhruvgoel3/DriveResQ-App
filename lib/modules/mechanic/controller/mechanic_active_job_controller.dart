import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MechanicActiveJobController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  var activeJob = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    listenToActiveJob();
  }

  void listenToActiveJob() {
    _firestore
        .collection('requests')
        .where('mechanicId', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        activeJob.value = {
          ...snapshot.docs.first.data(),
          'id': snapshot.docs.first.id,
        };
      } else {
        activeJob.value = null;
      }
    });
  }
}
