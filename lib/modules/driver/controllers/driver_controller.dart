import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DriverController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var hasActiveRequest = false.obs;
  var requestData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    listenToActiveRequest();
  }

  void listenToActiveRequest() {
    final uid = _auth.currentUser!.uid;

    _firestore
        .collection('requests')
        .where('driverId', isEqualTo: uid)
        .where('status', whereIn: ['open', 'accepted'])
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            hasActiveRequest.value = true;
            requestData.value = {
              ...snapshot.docs.first.data(),
              'id': snapshot.docs.first.id, // 🔥 IMPORTANT
            };
          } else {
            hasActiveRequest.value = false;
            requestData.value = null;
          }
        });
  }

  Future<void> cancelActiveRequest() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection('requests')
        .where('driverId', isEqualTo: uid)
        .where('status', whereIn: ['open', 'accepted'])
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await _firestore
          .collection('requests')
          .doc(snapshot.docs.first.id)
          .update({'status': 'cancelled'});
    }
  }
}
