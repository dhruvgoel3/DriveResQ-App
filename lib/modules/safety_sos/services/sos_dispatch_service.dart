import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact_model.dart';
import '../models/sos_incident_model.dart';

/// Handles persisting SOS incidents and dispatching emergency messages
/// to all enabled emergency contacts.
///
/// ## Delivery strategy
///
/// DriveResQ does not currently have a server-side SMS provider configured.
/// Therefore, this service uses the following fallback strategy:
///
///   1. Build the emergency message with location and request details.
///   2. For each enabled contact, attempt to open WhatsApp with the prefilled message.
///      (The user must press Send — this cannot be done silently on iOS,
///       and requires WhatsApp to be installed.)
///   3. Record each contact's delivery status accurately.
///
/// **The status is set to `fallback_required` (not "sent"), clearly indicating
/// that the user must complete sending via the opened interface.**
///
/// When an SMS backend (e.g. Twilio) is configured, replace [_dispatchToContact]
/// with a server-side API call and update the status values accordingly.
///
/// Incidents are stored at: `sos_incidents/{incidentId}`
class SosDispatchService {
  static final _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _incidentsRef =>
      _firestore.collection('sos_incidents');

  /// Generate a new incident document reference so its ID is known BEFORE dispatching.
  static DocumentReference<Map<String, dynamic>> newIncidentRef() {
    return _incidentsRef.doc();
  }

  /// Persist a new SOS incident document with a predetermined ID.
  static Future<void> saveIncidentWithId(SosIncident incident) async {
    try {
      await _incidentsRef.doc(incident.id).set(incident.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('SosDispatchService: Failed to save incident ${incident.id} — $e');
      rethrow;
    }
  }

  /// Persist a new SOS incident document and return its ID.
  ///
  /// Uses a Firestore auto-generated ID for idempotency.
  static Future<String> createIncident(SosIncident incident) async {
    try {
      if (incident.id.isNotEmpty) {
        await saveIncidentWithId(incident);
        return incident.id;
      }
      final docRef = await _incidentsRef.add(incident.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('SosDispatchService: Failed to create incident — $e');
      rethrow;
    }
  }

  /// Update an existing incident document.
  static Future<void> updateIncident(SosIncident incident) async {
    try {
      await _incidentsRef.doc(incident.id).update(incident.toMap());
    } catch (e) {
      debugPrint('SosDispatchService: Failed to update incident ${incident.id} — $e');
      rethrow;
    }
  }

  /// Dispatch the emergency message to all [contacts].
  ///
  /// Returns a list of [ContactDeliveryRecord] with the result for each contact.
  ///
  /// This method processes each contact independently so that one failure
  /// does not block notification of others.
  static Future<List<ContactDeliveryRecord>> dispatchToAllContacts({
    required String message,
    required List<EmergencyContact> contacts,
  }) async {
    final records = <ContactDeliveryRecord>[];

    for (final contact in contacts) {
      if (!contact.isEnabled) {
        records.add(ContactDeliveryRecord(
          contactId: contact.id,
          contactName: contact.name,
          contactPhone: contact.phone,
          status: 'skipped',
          note: 'Contact is disabled.',
          attemptedAt: DateTime.now(),
        ));
        continue;
      }

      final record = await _dispatchToContact(contact: contact, message: message);
      records.add(record);

      // Brief pause between contacts to prevent rapid URL-scheme calls being
      // blocked by the OS on some devices.
      await Future.delayed(const Duration(milliseconds: 400));
    }

    return records;
  }

  /// Attempt to open WhatsApp for [contact] with the prefilled [message].
  ///
  /// Status meanings:
  ///   `fallback_required` — WhatsApp opened; user must press Send.
  ///   `skipped`           — WhatsApp not installed or link could not be launched.
  static Future<ContactDeliveryRecord> _dispatchToContact({
    required EmergencyContact contact,
    required String message,
  }) async {
    final now = DateTime.now();
    try {
      // WhatsApp deep-link; phone must include country code without +
      final phoneDigits = contact.phone.replaceAll('+', '');
      final encodedMsg = Uri.encodeComponent(message);
      final waUri = Uri.parse('https://wa.me/$phoneDigits?text=$encodedMsg');

      if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri, mode: LaunchMode.externalApplication);
        return ContactDeliveryRecord(
          contactId: contact.id,
          contactName: contact.name,
          contactPhone: contact.phone,
          status: 'fallback_required',
          note: 'WhatsApp opened. Please press Send to complete delivery.',
          attemptedAt: now,
        );
      } else {
        // WhatsApp not available — try SMS composer
        final smsUri = Uri.parse(
          'sms:${contact.phone}?body=${Uri.encodeComponent(message)}',
        );
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
          return ContactDeliveryRecord(
            contactId: contact.id,
            contactName: contact.name,
            contactPhone: contact.phone,
            status: 'fallback_required',
            note: 'SMS composer opened. Please press Send.',
            attemptedAt: now,
          );
        }

        return ContactDeliveryRecord(
          contactId: contact.id,
          contactName: contact.name,
          contactPhone: contact.phone,
          status: 'skipped',
          note: 'Could not open WhatsApp or SMS for this contact.',
          attemptedAt: now,
        );
      }
    } catch (e) {
      debugPrint('SosDispatchService: Error dispatching to ${contact.phone} — $e');
      return ContactDeliveryRecord(
        contactId: contact.id,
        contactName: contact.name,
        contactPhone: contact.phone,
        status: 'skipped',
        note: 'Error: $e',
        attemptedAt: now,
      );
    }
  }

  /// Build the emergency message string including real-time live tracking link and navigation.
  static String buildMessage({
    required String driverName,
    required String helpRequestId,
    String? incidentId,
    String? liveTrackingUrl,
    String? mechanicId,
    double? latitude,
    double? longitude,
    DateTime? locationCapturedAt,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🚨 EMERGENCY SOS ALERT — DriveResQ');
    buffer.writeln();
    buffer.writeln(
      'I may be in an unsafe situation and need immediate help!',
    );
    buffer.writeln();
    buffer.writeln('👤 Driver: $driverName');
    buffer.writeln('🆔 Help Request ID: $helpRequestId');
    if (mechanicId != null && mechanicId.isNotEmpty) {
      buffer.writeln('🔧 Mechanic ID: $mechanicId');
    }
    buffer.writeln();

    // 🔴 Real-time Live Tracking Link
    final trackerUrl = liveTrackingUrl ??
        (incidentId != null && incidentId.isNotEmpty
            ? 'https://driveresq-app.web.app/sos-track.html?id=$incidentId'
            : null);

    if (trackerUrl != null) {
      buffer.writeln('🔴 REAL-TIME LIVE LOCATION (Tap to track me live):');
      buffer.writeln(trackerUrl);
      buffer.writeln('👆 This link continuously updates my moving position in real-time. Keep it open in your browser.');
      buffer.writeln();
    }

    if (latitude != null && longitude != null) {
      final mapsLink =
          'https://www.google.com/maps?q=${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
      final navLink =
          'https://www.google.com/maps/dir/?api=1&destination=${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';

      buffer.writeln('📍 Initial GPS Pin: $mapsLink');
      buffer.writeln('🚗 Direct Navigation to Me: $navLink');
      if (locationCapturedAt != null) {
        buffer.writeln(
          'Captured at: ${_formatTime(locationCapturedAt)}',
        );
      }
    } else {
      buffer.writeln(
        '📍 GPS Fix: Acquiring live satellite coordinates…',
      );
    }

    buffer.writeln();
    buffer.writeln('⚠️ Status: Live GPS broadcast is active.');
    buffer.writeln('Please contact me immediately or alert local emergency services (112).');
    buffer.writeln();
    buffer.writeln('Generated by DriveResQ Safety SOS.');

    return buffer.toString().trim();
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $h:$m:$s';
  }

  /// Fetch a single incident by ID.
  static Future<SosIncident?> fetchIncident(String id) async {
    try {
      final doc = await _incidentsRef.doc(id).get();
      if (!doc.exists) return null;
      return SosIncident.fromMap(doc.data()!, docId: doc.id);
    } catch (e) {
      debugPrint('SosDispatchService: Failed to fetch incident $id — $e');
      return null;
    }
  }

  /// Stream a single incident for real-time status updates.
  static Stream<SosIncident?> watchIncident(String id) {
    return _incidentsRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return SosIncident.fromMap(doc.data()!, docId: doc.id);
    });
  }

  /// Fetch all incidents for a driver, ordered by newest first.
  static Future<List<SosIncident>> fetchIncidentsForDriver(String driverId) async {
    try {
      final snap = await _incidentsRef
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      return snap.docs
          .map((d) => SosIncident.fromMap(d.data(), docId: d.id))
          .toList();
    } catch (e) {
      debugPrint('SosDispatchService: Failed to fetch incidents for $driverId — $e');
      return [];
    }
  }
}
