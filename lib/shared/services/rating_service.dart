import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Submit a rating for a specific user (can be driver or mechanic)
  /// This will update their global average rating using a transaction.
  static Future<void> submitRating({
    required String targetUserId,
    required double newRating,
    required String reviewerId,
    String reviewText = '',
  }) async {
    final userRef = _firestore.collection('users').doc(targetUserId);
    final reviewsRef = userRef.collection('reviews').doc(); // Save individual review

    try {
      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception("User does not exist");
        }

        final data = userSnapshot.data()!;
        final currentCount = (data['ratingCount'] ?? 0) as int;
        final currentAvg = (data['averageRating'] ?? 0.0) as double;

        // Calculate new average
        final newCount = currentCount + 1;
        final newAvg = ((currentAvg * currentCount) + newRating) / newCount;

        transaction.update(userRef, {
          'ratingCount': newCount,
          'averageRating': newAvg,
        });

        transaction.set(reviewsRef, {
          'reviewerId': reviewerId,
          'rating': newRating,
          'reviewText': reviewText,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint("Error submitting rating: $e");
      rethrow;
    }
  }
}
