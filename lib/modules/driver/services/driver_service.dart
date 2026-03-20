import 'package:cloud_firestore/cloud_firestore.dart';


class DriverService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cancels an active request
  static Future<void> cancelActiveRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  /// Returns a stream of the mechanic's location
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getMechanicLocationStream(String mechanicId) {
    return _firestore
        .collection('mechanic_locations')
        .doc(mechanicId)
        .snapshots();
  }
}
