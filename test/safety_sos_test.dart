import 'package:flutter_test/flutter_test.dart';
import 'package:driveresq_app/modules/safety_sos/models/emergency_contact_model.dart';
import 'package:driveresq_app/modules/safety_sos/models/sos_incident_model.dart';
import 'package:driveresq_app/modules/safety_sos/services/emergency_contact_service.dart';
import 'package:driveresq_app/modules/safety_sos/services/shake_detection_service.dart';
import 'package:driveresq_app/modules/safety_sos/services/sos_dispatch_service.dart';

void main() {
  group('1. Emergency Contact Tests', () {
    test('Normalizes Indian 10-digit phone number with +91 country prefix', () {
      final normalized = EmergencyContactService.normalizePhone('9812244931');
      expect(normalized, '+919812244931');
    });

    test('Preserves already normalized international number', () {
      final normalized = EmergencyContactService.normalizePhone('+14155552671');
      expect(normalized, '+14155552671');
    });

    test('Strips spaces, dashes, parentheses and punctuation', () {
      final normalized = EmergencyContactService.normalizePhone('(981) 224-4931');
      expect(normalized, '+919812244931');
    });

    test('Rejects invalid phone number format', () {
      expect(
        () => EmergencyContactService.validatePhone('123'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => EmergencyContactService.validatePhone('abcdefghij'),
        throwsA(isA<Exception>()),
      );
    });

    test('Serializes to and from JSON for local offline cache persistence', () {
      final now = DateTime.now();
      final contact = EmergencyContact(
        id: 'contact_001',
        name: 'Rajesh Sharma',
        phone: '+919812244931',
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = contact.toJson();
      final revived = EmergencyContact.fromJson(json);

      expect(revived.id, contact.id);
      expect(revived.name, contact.name);
      expect(revived.phone, contact.phone);
      expect(revived.isEnabled, isTrue);
    });
  });

  group('2. Shake Detection Algorithm Tests', () {
    test('Default thresholds align with physical hand-shake calibration', () {
      expect(ShakeDetectionService.defaultThreshold, 13.0);
      expect(ShakeDetectionService.defaultRequiredShakes, 3);
      expect(ShakeDetectionService.defaultShakeWindow, const Duration(milliseconds: 2000));
      expect(ShakeDetectionService.defaultDebounce, const Duration(milliseconds: 250));
      expect(ShakeDetectionService.defaultCooldown, const Duration(seconds: 5));
    });

    test('Shake service initializes and stops cleanly', () {
      int triggerCount = 0;
      final service = ShakeDetectionService(
        onShakeDetected: () => triggerCount++,
        threshold: 12.0,
      );

      expect(service.isListening, isFalse);
      expect(service.isInCooldown, isFalse);
      service.stop();
      expect(triggerCount, 0);
    });
  });

  group('3. SOS Incident & Real-Time Live Tracking Dispatch Tests', () {
    test('Builds structured emergency message with Real-Time Live Tracking URL, GPS Pin, and Nav Route', () {
      final message = SosDispatchService.buildMessage(
        incidentId: 'INC_TEST_12345',
        driverName: 'Vikram Singh',
        helpRequestId: 'REQ-8849',
        mechanicId: 'MECH-102',
        latitude: 28.6139,
        longitude: 77.2090,
        locationCapturedAt: DateTime(2026, 10, 12, 14, 30),
      );

      expect(message.contains('EMERGENCY SOS ALERT — DriveResQ'), isTrue);
      expect(message.contains('Driver: Vikram Singh'), isTrue);
      expect(message.contains('Help Request ID: REQ-8849'), isTrue);
      expect(message.contains('Mechanic ID: MECH-102'), isTrue);
      expect(message.contains('REAL-TIME LIVE LOCATION'), isTrue);
      expect(message.contains('https://driveresq-app.web.app/sos-track.html?id=INC_TEST_12345'), isTrue);
      expect(message.contains('https://www.google.com/maps?q=28.613900,77.209000'), isTrue);
      expect(message.contains('https://www.google.com/maps/dir/?api=1&destination=28.613900,77.209000'), isTrue);
    });

    test('Builds emergency message gracefully when initial GPS coordinates are pending', () {
      final message = SosDispatchService.buildMessage(
        incidentId: 'INC_TEST_PENDING',
        driverName: 'Vikram Singh',
        helpRequestId: 'REQ-8849',
        latitude: null,
        longitude: null,
      );

      expect(message.contains('EMERGENCY SOS ALERT — DriveResQ'), isTrue);
      expect(message.contains('https://driveresq-app.web.app/sos-track.html?id=INC_TEST_PENDING'), isTrue);
      expect(message.contains('📍 GPS Fix: Acquiring live satellite coordinates…'), isTrue);
    });

    test('SosIncident serializes and deserializes live tracking telemetry fields', () {
      final now = DateTime.now();
      final incident = SosIncident(
        id: 'inc_999',
        driverId: 'drv_123',
        driverName: 'Vikram Singh',
        helpRequestId: 'REQ-8849',
        mechanicId: 'MECH-102',
        status: SosIncidentStatus.sent,
        triggerType: SosTriggerType.shake,
        createdAt: now,
        updatedAt: now,
        latitude: 28.6139,
        longitude: 77.2090,
        liveLatitude: 28.6145,
        liveLongitude: 77.2098,
        liveSpeed: 12.4,
        liveHeading: 95.0,
        isLiveTrackingActive: true,
        liveTrackingUrl: 'https://driveresq-app.web.app/sos-track.html?id=inc_999',
        locationAccuracy: 12.5,
        locationCapturedAt: now,
        locationStatus: 'available',
        message: 'Help needed',
        deliveryRecords: [
          ContactDeliveryRecord(
            contactId: 'c1',
            contactName: 'Pooja',
            contactPhone: '+919812244931',
            status: 'fallback_required',
            note: 'WhatsApp opened',
            attemptedAt: now,
          ),
        ],
      );

      final map = incident.toMap();
      expect(map['driverId'], 'drv_123');
      expect(map['status'], 'sent');
      expect(map['triggerType'], 'shake');
      expect(map['liveLatitude'], 28.6145);
      expect(map['liveLongitude'], 77.2098);
      expect(map['liveSpeed'], 12.4);
      expect(map['isLiveTrackingActive'], isTrue);
      expect(map['liveTrackingUrl'], 'https://driveresq-app.web.app/sos-track.html?id=inc_999');
      expect(map['deliveryRecords'], isNotEmpty);

      final revived = SosIncident.fromMap(map, docId: 'inc_999');
      expect(revived.id, 'inc_999');
      expect(revived.driverId, incident.driverId);
      expect(revived.status, SosIncidentStatus.sent);
      expect(revived.liveLatitude, 28.6145);
      expect(revived.liveLongitude, 77.2098);
      expect(revived.isLiveTrackingActive, isTrue);
      expect(revived.deliveryRecords.first.status, 'fallback_required');
    });

    test('SosIncident supports resolved status and copyWith updates', () {
      final now = DateTime.now();
      final incident = SosIncident(
        id: 'temp_id',
        driverId: 'drv_123',
        helpRequestId: 'REQ-1',
        status: SosIncidentStatus.sent,
        isLiveTrackingActive: true,
        triggerType: SosTriggerType.manual,
        createdAt: now,
        updatedAt: now,
        locationStatus: 'available',
        message: 'msg',
        deliveryRecords: const [],
      );

      final resolved = incident.copyWith(
        id: 'firestore_persisted_id',
        status: SosIncidentStatus.resolved,
        isLiveTrackingActive: false,
      );

      expect(resolved.id, 'firestore_persisted_id');
      expect(resolved.status, SosIncidentStatus.resolved);
      expect(resolved.isLiveTrackingActive, isFalse);
      expect(resolved.status.value, 'resolved');
    });
  });
}
