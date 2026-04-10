import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../utils/helpers/app_snackbar.dart';

class FavoritesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable list of favorited mechanic IDs
  var favoriteMechanicIds = <String>[].obs;

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _listenToFavorites();
  }

  void _listenToFavorites() {
    if (currentUserId == null) return;

    _firestore.collection('users').doc(currentUserId).snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final favoritesData = data['favoriteMechanics'] as List<dynamic>?;
        if (favoritesData != null) {
          favoriteMechanicIds.value = List<String>.from(favoritesData);
        } else {
          favoriteMechanicIds.clear();
        }
      }
    });
  }

  Future<void> addFavorite(String mechanicId) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'favoriteMechanics': FieldValue.arrayUnion([mechanicId]),
      });

      AppSnackbar.success(
        'You can quickly book this mechanic from your favorites',
        title: 'Added to Favorites',
      );
    } catch (e) {
      /* print stripped */
    }
  }

  Future<void> removeFavorite(String mechanicId) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'favoriteMechanics': FieldValue.arrayRemove([mechanicId]),
      });
    } catch (e) {
      /* print stripped */
    }
  }

  bool isFavorited(String mechanicId) {
    // Explicit .toList() to register read with GetX
    return favoriteMechanicIds.toList().contains(mechanicId);
  }

  void toggleFavorite(String mechanicId) {
    if (isFavorited(mechanicId)) {
      removeFavorite(mechanicId);
    } else {
      addFavorite(mechanicId);
    }
  }
}
