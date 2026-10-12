import 'package:cloud_firestore/cloud_firestore.dart';

/// Possible SOS trigger types.
enum SosTriggerType { shake, manual }

/// Lifecycle states for an SOS incident.
enum SosIncidentStatus {
  created,
  locationPending,
  dispatching,
  partiallySent,
  sent,
  resolved,
  failed,
  cancelled,
}

extension SosIncidentStatusExtension on SosIncidentStatus {
  String get value {
    switch (this) {
      case SosIncidentStatus.created:
        return 'created';
      case SosIncidentStatus.locationPending:
        return 'location_pending';
      case SosIncidentStatus.dispatching:
        return 'dispatching';
      case SosIncidentStatus.partiallySent:
        return 'partially_sent';
      case SosIncidentStatus.sent:
        return 'sent';
      case SosIncidentStatus.resolved:
        return 'resolved';
      case SosIncidentStatus.failed:
        return 'failed';
      case SosIncidentStatus.cancelled:
        return 'cancelled';
    }
  }

  static SosIncidentStatus fromString(String s) {
    switch (s) {
      case 'location_pending':
        return SosIncidentStatus.locationPending;
      case 'dispatching':
        return SosIncidentStatus.dispatching;
      case 'partially_sent':
        return SosIncidentStatus.partiallySent;
      case 'sent':
        return SosIncidentStatus.sent;
      case 'resolved':
        return SosIncidentStatus.resolved;
      case 'failed':
        return SosIncidentStatus.failed;
      case 'cancelled':
        return SosIncidentStatus.cancelled;
      case 'created':
      default:
        return SosIncidentStatus.created;
    }
  }
}

/// Per-contact delivery record within a SOS incident.
class ContactDeliveryRecord {
  final String contactId;
  final String contactName;
  final String contactPhone;
  final String status; // pending | opened | fallback_required | skipped
  final String? note;
  final DateTime? attemptedAt;

  const ContactDeliveryRecord({
    required this.contactId,
    required this.contactName,
    required this.contactPhone,
    required this.status,
    this.note,
    this.attemptedAt,
  });

  factory ContactDeliveryRecord.fromMap(Map<String, dynamic> map) {
    return ContactDeliveryRecord(
      contactId: map['contactId'] as String? ?? '',
      contactName: map['contactName'] as String? ?? '',
      contactPhone: map['contactPhone'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      note: map['note'] as String?,
      attemptedAt: _parseTimestamp(map['attemptedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contactId': contactId,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'status': status,
      'note': note,
      'attemptedAt': attemptedAt != null ? Timestamp.fromDate(attemptedAt!) : null,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

/// A complete SOS incident record.
///
/// Stored in Firestore at: `sos_incidents/{incidentId}`
class SosIncident {
  final String id;
  final String driverId;
  final String? driverName;
  final String helpRequestId;
  final String? mechanicId;
  final SosIncidentStatus status;
  final SosTriggerType triggerType;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Location fields
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;
  final DateTime? locationCapturedAt;
  final String locationStatus; // pending | available | last_known | unavailable

  // Real-time live tracking fields
  final double? liveLatitude;
  final double? liveLongitude;
  final double? liveAccuracy;
  final double? liveSpeed;
  final double? liveHeading;
  final bool isLiveTrackingActive;
  final DateTime? lastLocationUpdate;
  final String? liveTrackingUrl;

  // Dispatch fields
  final String message;
  final List<ContactDeliveryRecord> deliveryRecords;

  const SosIncident({
    required this.id,
    required this.driverId,
    this.driverName,
    required this.helpRequestId,
    this.mechanicId,
    required this.status,
    required this.triggerType,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.locationCapturedAt,
    required this.locationStatus,
    this.liveLatitude,
    this.liveLongitude,
    this.liveAccuracy,
    this.liveSpeed,
    this.liveHeading,
    this.isLiveTrackingActive = true,
    this.lastLocationUpdate,
    this.liveTrackingUrl,
    required this.message,
    required this.deliveryRecords,
  });

  factory SosIncident.fromMap(Map<String, dynamic> map, {required String docId}) {
    final rawDelivery = map['deliveryRecords'] as List<dynamic>? ?? [];
    return SosIncident(
      id: docId,
      driverId: map['driverId'] as String? ?? '',
      driverName: map['driverName'] as String?,
      helpRequestId: map['helpRequestId'] as String? ?? '',
      mechanicId: map['mechanicId'] as String?,
      status: SosIncidentStatusExtension.fromString(map['status'] as String? ?? 'created'),
      triggerType: (map['triggerType'] as String?) == 'manual'
          ? SosTriggerType.manual
          : SosTriggerType.shake,
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(map['updatedAt']) ?? DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationAccuracy: (map['locationAccuracy'] as num?)?.toDouble(),
      locationCapturedAt: _parseTimestamp(map['locationCapturedAt']),
      locationStatus: map['locationStatus'] as String? ?? 'pending',
      liveLatitude: (map['liveLatitude'] as num?)?.toDouble() ?? (map['latitude'] as num?)?.toDouble(),
      liveLongitude: (map['liveLongitude'] as num?)?.toDouble() ?? (map['longitude'] as num?)?.toDouble(),
      liveAccuracy: (map['liveAccuracy'] as num?)?.toDouble() ?? (map['locationAccuracy'] as num?)?.toDouble(),
      liveSpeed: (map['liveSpeed'] as num?)?.toDouble(),
      liveHeading: (map['liveHeading'] as num?)?.toDouble(),
      isLiveTrackingActive: map['isLiveTrackingActive'] as bool? ?? true,
      lastLocationUpdate: _parseTimestamp(map['lastLocationUpdate']),
      liveTrackingUrl: map['liveTrackingUrl'] as String?,
      message: map['message'] as String? ?? '',
      deliveryRecords: rawDelivery
          .map((e) => ContactDeliveryRecord.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'helpRequestId': helpRequestId,
      'mechanicId': mechanicId,
      'status': status.value,
      'triggerType': triggerType == SosTriggerType.manual ? 'manual' : 'shake',
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'latitude': latitude,
      'longitude': longitude,
      'locationAccuracy': locationAccuracy,
      'locationCapturedAt':
          locationCapturedAt != null ? Timestamp.fromDate(locationCapturedAt!) : null,
      'locationStatus': locationStatus,
      'liveLatitude': liveLatitude ?? latitude,
      'liveLongitude': liveLongitude ?? longitude,
      'liveAccuracy': liveAccuracy ?? locationAccuracy,
      'liveSpeed': liveSpeed,
      'liveHeading': liveHeading,
      'isLiveTrackingActive': isLiveTrackingActive,
      'lastLocationUpdate':
          lastLocationUpdate != null ? Timestamp.fromDate(lastLocationUpdate!) : null,
      'liveTrackingUrl': liveTrackingUrl,
      'message': message,
      'deliveryRecords': deliveryRecords.map((r) => r.toMap()).toList(),
    };
  }

  SosIncident copyWith({
    String? id,
    SosIncidentStatus? status,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    DateTime? locationCapturedAt,
    String? locationStatus,
    double? liveLatitude,
    double? liveLongitude,
    double? liveAccuracy,
    double? liveSpeed,
    double? liveHeading,
    bool? isLiveTrackingActive,
    DateTime? lastLocationUpdate,
    String? liveTrackingUrl,
    String? message,
    List<ContactDeliveryRecord>? deliveryRecords,
    DateTime? updatedAt,
  }) {
    return SosIncident(
      id: id ?? this.id,
      driverId: driverId,
      driverName: driverName,
      helpRequestId: helpRequestId,
      mechanicId: mechanicId,
      status: status ?? this.status,
      triggerType: triggerType,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      locationCapturedAt: locationCapturedAt ?? this.locationCapturedAt,
      locationStatus: locationStatus ?? this.locationStatus,
      liveLatitude: liveLatitude ?? this.liveLatitude,
      liveLongitude: liveLongitude ?? this.liveLongitude,
      liveAccuracy: liveAccuracy ?? this.liveAccuracy,
      liveSpeed: liveSpeed ?? this.liveSpeed,
      liveHeading: liveHeading ?? this.liveHeading,
      isLiveTrackingActive: isLiveTrackingActive ?? this.isLiveTrackingActive,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      liveTrackingUrl: liveTrackingUrl ?? this.liveTrackingUrl,
      message: message ?? this.message,
      deliveryRecords: deliveryRecords ?? this.deliveryRecords,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
