import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a trusted emergency contact configured by a driver.
///
/// Stored in Firestore at:
///   `emergency_contacts/{driverId}/contacts/{contactId}`
class EmergencyContact {
  final String id;
  final String name;
  final String phone; // normalized international format e.g. +919876543210
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map, {required String docId}) {
    return EmergencyContact(
      id: docId,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      isEnabled: map['isEnabled'] as bool? ?? true,
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'isEnabled': isEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  EmergencyContact copyWith({
    String? name,
    String? phone,
    bool? isEnabled,
    DateTime? updatedAt,
  }) {
    return EmergencyContact(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  @override
  String toString() => 'EmergencyContact(id: $id, name: $name, phone: $phone, enabled: $isEnabled)';
}
