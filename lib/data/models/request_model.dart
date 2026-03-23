import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String? id;
  final String driverId;
  final String locationName;
  final String landmark;
  final String vehicleType;
  final String problem;
  final String? description;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;

  // Driver info
  final String? driverName;
  final String? driverPhone;
  final String? driverPhoto;
  final double? driverLat;
  final double? driverLng;

  // Mechanic info (set after acceptance)
  final String? mechanicId;
  final String? mechanicPhone;
  final String? verificationCode;

  RequestModel({
    this.id,
    required this.driverId,
    required this.locationName,
    required this.landmark,
    required this.vehicleType,
    required this.problem,
    this.description,
    this.imageUrl,
    this.status = 'open',
    required this.createdAt,
    this.driverName,
    this.driverPhone,
    this.driverPhoto,
    this.driverLat,
    this.driverLng,
    this.mechanicId,
    this.mechanicPhone,
    this.verificationCode,
  });

  /// Null-safe factory from Firestore document data.
  factory RequestModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return RequestModel(
      id: docId ?? map['id'] as String?,
      driverId: map['driverId'] as String? ?? '',
      locationName: map['locationName'] as String? ?? '',
      landmark: map['landmark'] as String? ?? '',
      vehicleType: map['vehicleType'] as String? ?? '',
      problem: map['problem'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: map['imageUrl'] as String?,
      status: map['status'] as String? ?? 'open',
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      driverName: map['driverName'] as String?,
      driverPhone: map['driverPhone'] as String?,
      driverPhoto: map['driverPhoto'] as String?,
      driverLat: (map['driverLat'] as num?)?.toDouble(),
      driverLng: (map['driverLng'] as num?)?.toDouble(),
      mechanicId: map['mechanicId'] as String?,
      mechanicPhone: map['mechanicPhone'] as String?,
      verificationCode: map['verificationCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'locationName': locationName,
      'landmark': landmark,
      'vehicleType': vehicleType,
      'problem': problem,
      'description': description,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
