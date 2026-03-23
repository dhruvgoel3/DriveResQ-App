import 'package:cloud_firestore/cloud_firestore.dart';

/// Typed model for user documents in Firestore.
/// Provides null-safe parsing via [fromMap] and serialization via [toMap].
class UserModel {
  final String uid;
  final String? phone;
  final String role;
  final String fullName;
  final String? profilePhotoUrl;
  final bool isActive;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Driver-specific
  final bool driverOnboardingCompleted;

  // Mechanic-specific
  final bool onboardingCompleted;
  final String verificationStatus; // '', 'pending', 'approved', 'rejected'
  final String? shopName;
  final List<String> servicesOffered;
  final List<String> specializations;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int jobsCompleted;
  final bool isOnline;

  const UserModel({
    required this.uid,
    this.phone,
    this.role = '',
    this.fullName = '',
    this.profilePhotoUrl,
    this.isActive = true,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.driverOnboardingCompleted = false,
    this.onboardingCompleted = false,
    this.verificationStatus = '',
    this.shopName,
    this.servicesOffered = const [],
    this.specializations = const [],
    this.latitude,
    this.longitude,
    this.rating = 0.0,
    this.jobsCompleted = 0,
    this.isOnline = false,
  });

  /// Parse a Firestore document into a [UserModel] with null-safe fallbacks.
  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return UserModel(
      uid: docId ?? map['uid'] as String? ?? '',
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? '',
      fullName: map['fullName'] as String? ??
          map['name'] as String? ??
          '',
      profilePhotoUrl: map['profilePhotoUrl'] as String? ??
          map['photoUrl'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      fcmToken: map['fcmToken'] as String?,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
      driverOnboardingCompleted:
          map['driverOnboardingCompleted'] as bool? ?? false,
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      verificationStatus: map['verificationStatus'] as String? ?? '',
      shopName: map['shopName'] as String?,
      servicesOffered: List<String>.from(map['servicesOffered'] ?? []),
      specializations: List<String>.from(map['specializations'] ?? []),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      jobsCompleted: (map['jobsCompleted'] as num?)?.toInt() ?? 0,
      isOnline: map['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'role': role,
      'fullName': fullName,
      'profilePhotoUrl': profilePhotoUrl,
      'isActive': isActive,
      'fcmToken': fcmToken,
      'driverOnboardingCompleted': driverOnboardingCompleted,
      'onboardingCompleted': onboardingCompleted,
      'verificationStatus': verificationStatus,
      'shopName': shopName,
      'servicesOffered': servicesOffered,
      'specializations': specializations,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'jobsCompleted': jobsCompleted,
      'isOnline': isOnline,
    };
  }

  /// Display-friendly name with fallback.
  String get displayName =>
      fullName.isNotEmpty ? fullName : (phone ?? 'User');

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
