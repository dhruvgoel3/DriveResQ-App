import 'package:cloud_firestore/cloud_firestore.dart';

import '../../modules/notifications/services/notification_sender.dart';

/// A service dedicated to managing user ratings and reviews.
///
/// This service handles the atomic update of a user's average rating
/// while storing their review history in a sub-collection.
class RatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Submits a rating for a specific [targetUserId].
  ///
  /// Uses a Firestore [Transaction] to ensure the average calculation remains
  /// consistent even when multiple reviews are submitted simultaneously.
  static Future<void> submitRating({
    required String targetUserId,
    required double newRating,
    required String reviewerId,
    String reviewText = '',
  }) async {
    final userRef = _firestore.collection('users').doc(targetUserId);
    final reviewsRef = userRef.collection('reviews').doc();

    try {
      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception(
            "Service failure: Target user record does not exist.",
          );
        }

        final data = userSnapshot.data()!;
        final currentCount = (data['ratingCount'] ?? 0) as int;
        final currentAvg = (data['averageRating'] ?? 0.0) as double;

        // Atomic calculation of the new cumulative average
        final newCount = currentCount + 1;
        final newAvg = ((currentAvg * currentCount) + newRating) / newCount;

        // Apply updates
        transaction.update(userRef, {
          'ratingCount': newCount,
          'averageRating': newAvg,
        });

        transaction.set(reviewsRef, {
          'reviewerId': reviewerId,
          'rating': newRating,
          'reviewText': reviewText.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      // Notify the recipient about the new rating (Fire and Forget)
      NotificationSender.notifyRatingReceived(
        mechanicId: targetUserId,
        rating: newRating,
        review: reviewText,
      ).catchError((e) {});
    } catch (e) {
      rethrow;
    }
  }
}
