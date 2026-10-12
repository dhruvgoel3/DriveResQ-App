import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../utils/helpers/app_snackbar.dart';
import '../models/emergency_contact_model.dart';
import '../models/sos_incident_model.dart';
import '../services/emergency_contact_service.dart';
import '../services/shake_detection_service.dart';
import '../services/sos_dispatch_service.dart';
import '../services/sos_live_location_service.dart';
import '../views/sos_incident_status_screen.dart';

/// Coordinates the Shake-to-SOS feature lifecycle.
///
/// Responsibilities:
///   - Manage emergency contacts (CRUD operations + cache).
///   - Automatically track driver active roadside assistance requests in Firestore.
///   - Activate shake detection when an eligible request is accepted and feature is enabled.
///   - Initiate the 5-second countdown when a valid shake or manual trigger occurs.
///   - Idempotently create and dispatch SOS incidents with location and fallbacks.
///   - Track recipient dispatch status and display results.
class SafetySosController extends GetxController {
  // ── Observables ──────────────────────────────────────────────────────────
  final contacts = <EmergencyContact>[].obs;
  final isLoadingContacts = false.obs;
  final contactError = RxnString();

  final isShakeEnabled = true.obs;
  final isFeatureActive = false.obs; // true when mechanic has accepted request
  final activeRequestId = RxnString();
  final activeMechanicId = RxnString();
  final currentMagnitude = 0.0.obs;

  final isCountdownActive = false.obs;
  final countdownSeconds = 5.obs;

  final currentIncident = Rxn<SosIncident>();
  final isDispatching = false.obs;

  // ── Private state ────────────────────────────────────────────────────────
  ShakeDetectionService? _shakeService;
  StreamSubscription<List<EmergencyContact>>? _contactsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activeRequestSub;
  Timer? _countdownTimer;
  bool _countdownCancelled = false;
  bool _isDispatched = false;

  static const List<String> _eligibleStatuses = [
    'mechanic_accepted',
    'accepted',
    'verified',
    'in_progress',
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _subscribeContacts();
    _listenToActiveRequest();
  }

  @override
  void onClose() {
    _activeRequestSub?.cancel();
    _contactsSub?.cancel();
    _countdownTimer?.cancel();
    _shakeService?.dispose();
    _shakeService = null;
    super.onClose();
  }

  // ── Automatic Active Request Sync ─────────────────────────────────────────

  void _listenToActiveRequest() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _activeRequestSub?.cancel();
    _activeRequestSub = FirebaseFirestore.instance
        .collection('requests')
        .where('driverId', isEqualTo: uid)
        .where('status', whereIn: _eligibleStatuses)
        .limit(1)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final data = doc.data();
          onRequestStatusChanged(
            requestId: doc.id,
            status: data['status']?.toString(),
            mechanicId: data['mechanicId']?.toString(),
          );
        } else {
          onRequestStatusChanged(
            requestId: null,
            status: null,
            mechanicId: null,
          );
        }
      },
      onError: (Object err) {
        debugPrint('SafetySosController _activeRequestSub error: $err');
      },
    );
  }

  // ── Contact management ────────────────────────────────────────────────────

  void _subscribeContacts() {
    _contactsSub?.cancel();
    _contactsSub = EmergencyContactService.watchContacts().listen(
      (list) {
        contacts.assignAll(list);
        isLoadingContacts.value = false;
      },
      onError: (Object e) {
        contactError.value = 'Failed to load contacts: $e';
        isLoadingContacts.value = false;
      },
    );
    isLoadingContacts.value = true;
  }

  Future<void> addContact({required String name, required String phone}) async {
    try {
      await EmergencyContactService.addContact(name: name, phone: phone);
      AppSnackbar.success('Emergency contact added successfully.', title: 'Saved');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackbar.error(msg);
      rethrow;
    }
  }

  Future<void> updateContact(EmergencyContact contact) async {
    try {
      await EmergencyContactService.updateContact(contact);
      AppSnackbar.success('Contact updated.', title: 'Saved');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackbar.error(msg);
      rethrow;
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await EmergencyContactService.deleteContact(contactId);
      AppSnackbar.warning('Contact removed.', title: 'Deleted');
    } catch (e) {
      AppSnackbar.error('Failed to delete contact.');
    }
  }

  Future<void> toggleContact(String contactId, bool enabled) async {
    try {
      await EmergencyContactService.toggleContact(contactId, enabled);
    } catch (e) {
      AppSnackbar.error('Failed to update contact status.');
    }
  }

  // ── Feature activation ────────────────────────────────────────────────────

  /// Called whenever request status changes to align shake detection eligibility.
  void onRequestStatusChanged({
    required String? requestId,
    required String? status,
    required String? mechanicId,
  }) {
    final shouldBeActive =
        requestId != null && status != null && _eligibleStatuses.contains(status);

    if (shouldBeActive) {
      activeRequestId.value = requestId;
      activeMechanicId.value = mechanicId;
      isFeatureActive.value = true;
      if (isShakeEnabled.value) {
        _startShakeDetection();
      }
    } else {
      activeRequestId.value = null;
      activeMechanicId.value = null;
      isFeatureActive.value = false;
      _stopShakeDetection();
    }
  }

  /// Enable or disable shake detection in the UI settings toggle.
  void setShakeEnabled(bool enabled) {
    isShakeEnabled.value = enabled;
    if (enabled && isFeatureActive.value) {
      _startShakeDetection();
    } else {
      _stopShakeDetection();
    }
  }

  void _startShakeDetection() {
    if (_shakeService?.isListening ?? false) return;
    _shakeService?.dispose();
    _shakeService = ShakeDetectionService(
      onShakeDetected: _onShakeDetected,
      onMagnitudeSample: (mag) {
        currentMagnitude.value = mag;
      },
    );
    _shakeService!.start();
    debugPrint('SafetySosController: Shake detection listening started.');
  }

  void _stopShakeDetection() {
    _shakeService?.stop();
    debugPrint('SafetySosController: Shake detection stopped.');
  }

  // ── Shake detected → 5s Cancelable Countdown ──────────────────────────────

  void _onShakeDetected() {
    if (isCountdownActive.value || isDispatching.value) return;
    if (!isFeatureActive.value) return;
    _startCountdown(triggerType: SosTriggerType.shake);
  }

  /// Trigger SOS manually as a reliable fallback.
  void triggerManualSos() {
    if (isCountdownActive.value || isDispatching.value) return;
    _startCountdown(triggerType: SosTriggerType.manual);
  }

  void _startCountdown({required SosTriggerType triggerType}) {
    _countdownCancelled = false;
    _isDispatched = false;
    isCountdownActive.value = true;
    countdownSeconds.value = 5;

    // Pause shake sensor during active countdown
    _shakeService?.stop();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownCancelled) {
        timer.cancel();
        return;
      }
      countdownSeconds.value--;
      if (countdownSeconds.value <= 0) {
        timer.cancel();
        if (!_countdownCancelled && !_isDispatched) {
          _isDispatched = true;
          _onCountdownComplete(triggerType);
        }
      }
    });
  }

  /// User pressed CANCEL SOS.
  void cancelCountdown() {
    _countdownCancelled = true;
    _countdownTimer?.cancel();
    isCountdownActive.value = false;
    countdownSeconds.value = 5;

    // Resume shake detection if feature is still active
    if (isShakeEnabled.value && isFeatureActive.value) {
      _startShakeDetection();
    }
    AppSnackbar.info(
      'Emergency SOS cancelled. No alerts were dispatched.',
      title: 'Cancelled',
    );
  }

  // ── SOS confirmed → Dispatch to enabled contacts ─────────────────────────

  Future<void> _onCountdownComplete(SosTriggerType triggerType) async {
    isCountdownActive.value = false;
    isDispatching.value = true;

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final requestId = activeRequestId.value ?? 'manual_alert';
    final mechanicId = activeMechanicId.value;

    // 1. Fetch enabled contacts
    List<EmergencyContact> enabledContacts;
    try {
      enabledContacts = await EmergencyContactService.fetchEnabledContacts();
    } catch (e) {
      enabledContacts = [];
    }

    if (enabledContacts.isEmpty) {
      isDispatching.value = false;
      AppSnackbar.warning(
        'No emergency contacts configured or enabled. Please add trusted contacts in Safety SOS.',
        title: 'No Contacts',
      );
      if (isShakeEnabled.value && isFeatureActive.value) _startShakeDetection();
      return;
    }

    // 2. Pre-generate Incident ID & Live Tracking URL
    final incidentDocRef = SosDispatchService.newIncidentRef();
    final incidentId = incidentDocRef.id;
    final liveTrackingUrl = SosLiveLocationService.buildLiveTrackingUrl(incidentId);

    // 3. Acquire driver location with fallback
    final locationResult = await _getLocation();
    final lat = locationResult['lat'] as double?;
    final lng = locationResult['lng'] as double?;
    final accuracy = locationResult['accuracy'] as double?;
    final locStatus = locationResult['status'] as String;
    final locTime = locationResult['capturedAt'] as DateTime?;
    final rawPos = locationResult['position'] as Position?;

    // 4. Start continuous real-time GPS stream broadcast to Firestore
    await SosLiveLocationService.startLiveTracking(
      incidentId,
      initialPosition: rawPos,
    );

    // 5. Construct emergency message with real-time tracking link & navigation
    final message = SosDispatchService.buildMessage(
      driverName: FirebaseAuth.instance.currentUser?.displayName ?? 'Driver',
      helpRequestId: requestId,
      incidentId: incidentId,
      liveTrackingUrl: liveTrackingUrl,
      mechanicId: mechanicId,
      latitude: lat,
      longitude: lng,
      locationCapturedAt: locTime,
    );

    // 6. Pre-create incident in Firestore so emergency contacts opening the link find it immediately
    final initialIncident = SosIncident(
      id: incidentId,
      driverId: uid,
      driverName: FirebaseAuth.instance.currentUser?.displayName ?? 'Driver',
      helpRequestId: requestId,
      mechanicId: mechanicId,
      status: SosIncidentStatus.sent,
      triggerType: triggerType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      latitude: lat,
      longitude: lng,
      locationAccuracy: accuracy,
      locationCapturedAt: locTime,
      locationStatus: locStatus,
      liveLatitude: lat,
      liveLongitude: lng,
      liveAccuracy: accuracy,
      isLiveTrackingActive: true,
      lastLocationUpdate: DateTime.now(),
      liveTrackingUrl: liveTrackingUrl,
      message: message,
      deliveryRecords: [],
    );

    try {
      await SosDispatchService.saveIncidentWithId(initialIncident);
    } catch (e) {
      debugPrint('SafetySosController: Error saving initial incident: $e');
    }

    // 7. Dispatch alerts with real-time tracking link to each contact via WhatsApp
    List<ContactDeliveryRecord> deliveryRecords;
    try {
      deliveryRecords = await SosDispatchService.dispatchToAllContacts(
        contacts: enabledContacts,
        message: message,
      );
    } catch (e) {
      deliveryRecords = enabledContacts
          .map((c) => ContactDeliveryRecord(
                contactId: c.id,
                contactName: c.name,
                contactPhone: c.phone,
                status: 'error',
                note: e.toString(),
                attemptedAt: DateTime.now(),
              ))
          .toList();
    }

    // 8. Update incident with delivery records
    final finalIncident = initialIncident.copyWith(
      deliveryRecords: deliveryRecords,
    );

    try {
      await SosDispatchService.updateIncident(finalIncident);
    } catch (e) {
      debugPrint('SafetySosController: Error updating delivery records: $e');
    }

    currentIncident.value = finalIncident;
    isDispatching.value = false;

    // 9. Show recap / live tracking delivery status screen
    Get.to(() => const SosIncidentStatusScreen());

    // Resume shake detection if feature is still active
    if (isShakeEnabled.value && isFeatureActive.value) {
      _startShakeDetection();
    }
  }

  /// Stops real-time GPS broadcasting and marks the incident resolved.
  Future<void> resolveAndStopTracking() async {
    final inc = currentIncident.value;
    if (inc == null) return;

    await SosLiveLocationService.stopLiveTracking(inc.id);

    final updated = inc.copyWith(
      status: SosIncidentStatus.resolved,
      isLiveTrackingActive: false,
    );
    currentIncident.value = updated;
    await SosDispatchService.updateIncident(updated);

    AppSnackbar.success(
      'Emergency marked safe. Real-time location sharing stopped.',
      title: 'Resolved',
    );
  }

  // ── Geolocation acquisition with 8s timeout & last-known fallback ─────────

  Future<Map<String, dynamic>> _getLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {'status': 'unavailable', 'reason': 'Location services disabled'};
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        return {'status': 'unavailable', 'reason': 'Permission denied'};
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () async {
          final last = await Geolocator.getLastKnownPosition();
          if (last != null) return last;
          throw TimeoutException('GPS timeout');
        },
      );

      return {
        'lat': position.latitude,
        'lng': position.longitude,
        'accuracy': position.accuracy,
        'status': 'available',
        'capturedAt': DateTime.now(),
        'position': position,
      };
    } catch (e) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          return {
            'lat': last.latitude,
            'lng': last.longitude,
            'accuracy': last.accuracy,
            'status': 'last_known',
            'capturedAt': last.timestamp,
          };
        }
      } catch (_) {}
      return {'status': 'unavailable'};
    }
  }
}
