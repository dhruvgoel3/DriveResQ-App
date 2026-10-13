import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driveresq_app/modules/dues/models/platform_due.dart';

/// Server-authoritative platform dues service.
/// All monetary writes, dues ledger creation, and account unsuspension are handled
/// securely via Cloud Functions (Admin SDK). This service only reads and invokes callables.
class DuesService {
  DuesService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUid => _auth.currentUser?.uid;

  /// Stream list of platform dues for the current mechanic.
  /// Sorts in-memory so no composite index creation is required.
  static Stream<List<PlatformDue>> streamMyDues() {
    final uid = currentUid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('platformDues')
        .where('mechanicId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PlatformDue.fromMap(doc.data(), docId: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Stream outstanding balance and account status from users/{uid}.
  static Stream<Map<String, dynamic>?> streamOutstanding() {
    final uid = currentUid;
    if (uid == null) return Stream.value(null);

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() ?? {};
      final phone = (data['phoneNumber'] as String?) ??
          (data['phone'] as String?) ??
          _auth.currentUser?.phoneNumber ??
          '';
      return {
        'platformDueOutstanding':
            (data['platformDueOutstanding'] as num?)?.toDouble() ?? 0.0,
        'accountStatus': (data['accountStatus'] as String?) ?? 'active',
        'suspendedReason': data['suspendedReason'] as String?,
        'phoneNumber': phone,
        'email': (data['email'] as String?) ?? _auth.currentUser?.email ?? '',
        'name': data['name'] as String? ?? 'Mechanic',
      };
    });
  }

  /// Fetch a single snapshot of user data for checkout details (e.g. phone, email)
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = currentUid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    final phone = (data['phoneNumber'] as String?) ??
        (data['phone'] as String?) ??
        _auth.currentUser?.phoneNumber ??
        '';
    data['phoneNumber'] = phone;
    data['email'] = (data['email'] as String?) ?? _auth.currentUser?.email ?? '';
    return data;
  }

  /// Requests the server to calculate outstanding dues and create a Razorpay order.
  static Future<Map<String, dynamic>> createOrder() async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('User is not authenticated.');
    }

    final callable = _functions.httpsCallable(
      'createDuesOrder',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );

    final response = await callable.call();
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Submits the Razorpay payment details to Cloud Functions for cryptographic verification.
  /// Dues are only cleared and account unsuspended if HMAC SHA-256 signature matches.
  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final callable = _functions.httpsCallable(
      'verifyDuesPayment',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );

    final response = await callable.call({
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
    });

    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Calls server to backfill any completed jobs that were created before functions were deployed
  static Future<int> syncPendingDues() async {
    try {
      final callable = _functions.httpsCallable(
        'syncPendingDues',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
      );
      final response = await callable.call();
      final data = response.data as Map?;
      return (data?['count'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
