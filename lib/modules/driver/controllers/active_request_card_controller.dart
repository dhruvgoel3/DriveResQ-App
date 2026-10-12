import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../chat/controllers/chat_controller.dart';
import '../../chat/views/chat_screen.dart';
import '../services/driver_service.dart';
import '../../../utils/helpers/app_snackbar.dart';

enum MechanicLocationState {
  loading,
  available,
  unavailable,
  stale,
  error,
}

class ActiveRequestCardController extends GetxController {
  final Map<String, dynamic> request;

  ActiveRequestCardController(this.request);

  var mechanicLat = Rxn<double>();
  var mechanicLng = Rxn<double>();
  var hasLocation = false.obs;
  var locationState = MechanicLocationState.loading.obs;
  var statusMessage = 'Connecting to mechanic GPS...'.obs;

  double? initialLat;
  double? initialLng;
  var markers = <Marker>{}.obs;

  StreamSubscription? _requestStatusSubscription;
  StreamSubscription? _locationSubscription;
  Timer? _locationTimeoutTimer;
  GoogleMapController? mapController;

  static const List<String> _activeStatuses = [
    'mechanic_accepted',
    'accepted',
    'verified',
    'in_progress',
  ];

  @override
  void onInit() {
    super.onInit();
    final status = request['status']?.toString() ?? '';
    final mechanicId = request['mechanicId']?.toString();

    if (_activeStatuses.contains(status) && mechanicId != null && mechanicId.isNotEmpty) {
      _listenToMechanicLocation(mechanicId);
    }

    // Always watch request document for status/mechanic changes
    _watchForStatusChange();
  }

  void _watchForStatusChange() {
    final requestId = request['id']?.toString();
    if (requestId == null || requestId.isEmpty) return;

    _requestStatusSubscription?.cancel();
    _requestStatusSubscription = DriverService.getRequestStream(requestId).listen(
      (snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return;
        final data = snapshot.data()!;
        final updatedStatus = data['status']?.toString() ?? '';
        final newMechanicId = data['mechanicId']?.toString();

        request['status'] = updatedStatus;
        if (newMechanicId != null) {
          request['mechanicId'] = newMechanicId;
        }
        if (data['mechanicName'] != null) {
          request['mechanicName'] = data['mechanicName'];
        }
        if (data['mechanicPhone'] != null) {
          request['mechanicPhone'] = data['mechanicPhone'];
        }

        if (_activeStatuses.contains(updatedStatus) &&
            newMechanicId != null &&
            newMechanicId.isNotEmpty &&
            !hasLocation.value) {
          _listenToMechanicLocation(newMechanicId);
        }
      },
      onError: (Object err) {
        locationState.value = MechanicLocationState.error;
        statusMessage.value = 'Failed to sync request status';
      },
    );
  }

  @override
  void onClose() {
    _locationTimeoutTimer?.cancel();
    _requestStatusSubscription?.cancel();
    _locationSubscription?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  void _listenToMechanicLocation(String mechanicId) {
    _locationSubscription?.cancel();
    _locationTimeoutTimer?.cancel();

    locationState.value = MechanicLocationState.loading;
    statusMessage.value = 'Locating assigned mechanic...';

    // Start 10-second timeout for location availability
    _locationTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!hasLocation.value && locationState.value == MechanicLocationState.loading) {
        locationState.value = MechanicLocationState.unavailable;
        statusMessage.value = 'Mechanic is preparing to depart (GPS signal pending)';
      }
    });

    _locationSubscription = DriverService.getMechanicLocationStream(mechanicId).listen(
      (snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          if (!hasLocation.value) {
            locationState.value = MechanicLocationState.unavailable;
            statusMessage.value = 'Mechanic location not yet reported';
          }
          return;
        }

        final data = snapshot.data()!;
        final rawLat = data['latitude'];
        final rawLng = data['longitude'];

        if (rawLat != null && rawLng != null) {
          final lat = (rawLat as num).toDouble();
          final lng = (rawLng as num).toDouble();

          // Validate coordinates
          if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) {
            locationState.value = MechanicLocationState.error;
            statusMessage.value = 'Invalid coordinate data received';
            return;
          }

          mechanicLat.value = lat;
          mechanicLng.value = lng;
          hasLocation.value = true;
          _locationTimeoutTimer?.cancel();

          // Check staleness (> 15 minutes)
          final ts = _extractTimestamp(data['timestamp'] ?? data['updatedAt']);
          if (ts != null && DateTime.now().difference(ts).inMinutes > 15) {
            locationState.value = MechanicLocationState.stale;
            statusMessage.value = 'Location updated >15m ago';
          } else {
            locationState.value = MechanicLocationState.available;
            statusMessage.value = 'Live location active';
          }

          if (initialLat == null || initialLng == null) {
            initialLat = lat;
            initialLng = lng;
          }

          _updateMarkers();

          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
          );
        } else if (!hasLocation.value) {
          locationState.value = MechanicLocationState.unavailable;
          statusMessage.value = 'Mechanic coordinates pending';
        }
      },
      onError: (Object err) {
        _locationTimeoutTimer?.cancel();
        locationState.value = MechanicLocationState.error;
        statusMessage.value = 'Live location connection error';
      },
    );
  }

  DateTime? _extractTimestamp(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    return null;
  }

  void _updateMarkers() {
    if (mechanicLat.value == null || mechanicLng.value == null) return;

    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('mechanic'),
        position: LatLng(mechanicLat.value!, mechanicLng.value!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: request['mechanicName']?.toString() ?? 'Mechanic',
          snippet: 'Assigned Mechanic',
        ),
      ),
    );
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> callMechanic() async {
    final phone = request['mechanicPhone']?.toString();
    if (phone == null || phone.isEmpty) {
      AppSnackbar.error('Mechanic phone number not available');
      return;
    }

    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      AppSnackbar.error('Cannot make call');
    }
  }

  void openChat() {
    final chatId = request['id']?.toString() ?? '';
    if (chatId.isEmpty) {
      AppSnackbar.error('Chat not available yet');
      return;
    }

    Get.delete<ChatController>(force: true);
    Get.put(
      ChatController(
        chatId: chatId,
        otherUserName: request['mechanicName']?.toString() ?? 'Mechanic',
        otherUserPhoto: request['mechanicPhoto']?.toString() ?? '',
        myRole: 'driver',
      ),
    );

    Get.to(
      () => const ChatScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    );
  }

  void copyVerificationCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    AppSnackbar.success(
      'Verification code copied to clipboard',
      title: 'Copied!',
    );
  }

  void shareVerificationCode(String code) {
    // ignore: deprecated_member_use
    Share.share(
      'My DriveResQ roadside job verification code is: $code',
      subject: 'DriveResQ Job Verification Code',
    );
  }
}
