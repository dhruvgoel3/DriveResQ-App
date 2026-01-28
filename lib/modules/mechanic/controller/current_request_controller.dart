import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MechanicDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Tabs
  var selectedTab = 0.obs;
  void changeTab(int index) => selectedTab.value = index;

  // 🔹 Current Job
  var hasActiveJob = false.obs;
  var activeJob = Rxn<Map<String, dynamic>>();

  // 🔹 Open Requests
  var openRequests = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToActiveJob();
    _listenToOpenRequests();
  }

  // 🔥 LISTEN: ACCEPTED JOB FOR THIS MECHANIC
  void _listenToActiveJob() {
    final mechanicId = _auth.currentUser!.uid;

    _firestore
        .collection('requests')
        .where('mechanicId', isEqualTo: mechanicId)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();

        hasActiveJob.value = true;

        activeJob.value = {
          'requestId': doc.id,
          'vehicle': data['vehicleType'],
          'address': data['locationName'],
          'problem': data['problem'],
          'driverPhone': data['driverPhone'],
          'driverLat': data['driverLat'],
          'driverLng': data['driverLng'],
        };
      } else {
        hasActiveJob.value = false;
        activeJob.value = null;
      }
    });
  }

  // 🔥 LISTEN: OPEN REQUESTS (FOR ALL REQUESTS TAB)
  void _listenToOpenRequests() {
    _firestore
        .collection('requests')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .listen((snapshot) {
      openRequests.value = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }
}
