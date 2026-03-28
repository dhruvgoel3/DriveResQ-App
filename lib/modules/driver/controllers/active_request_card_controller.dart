import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../chat/controllers/chat_controller.dart';
import '../../chat/views/chat_screen.dart';
import '../services/driver_service.dart';

class ActiveRequestCardController extends GetxController {
  final Map<String, dynamic> request;

  ActiveRequestCardController(this.request);

  var mechanicLat = Rxn<double>();
  var mechanicLng = Rxn<double>();
  var markers = <Marker>{}.obs;

  StreamSubscription? _requestStatusSubscription;
  StreamSubscription? _locationSubscription;
  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    final status = request['status'];
    if (status == 'accepted') {
      _listenToMechanicLocation();
    } else {
      // Watch the request document for status changes (e.g. mechanic_accepted -> accepted)
      _watchForStatusChange();
    }
  }

  void _watchForStatusChange() {
    final requestId = request['id'];
    if (requestId == null) return;

    _requestStatusSubscription = DriverService.getRequestStream(requestId)
        .listen((snapshot) {
          if (!snapshot.exists) return;
          final data = snapshot.data()!;
          if (data['status'] == 'accepted' && mechanicLat.value == null) {
            // Status just changed to accepted — start tracking
            request['mechanicId'] = data['mechanicId'];
            request['status'] = 'accepted';
            _listenToMechanicLocation();
            _requestStatusSubscription?.cancel();
          }
        });
  }

  @override
  void onClose() {
    _requestStatusSubscription?.cancel();
    _locationSubscription?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  void _listenToMechanicLocation() {
    final mechanicId = request['mechanicId'];
    if (mechanicId == null) return;

    _locationSubscription?.cancel();
    _locationSubscription = DriverService.getMechanicLocationStream(mechanicId)
        .listen((snapshot) {
          if (!snapshot.exists) return;

          final data = snapshot.data()!;
          final lat = data['latitude'];
          final lng = data['longitude'];

          if (lat != null && lng != null) {
            mechanicLat.value = lat;
            mechanicLng.value = lng;
            _updateMarkers();

            mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
            );
          }
        });
  }

  void _updateMarkers() {
    if (mechanicLat.value == null || mechanicLng.value == null) return;

    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('mechanic'),
        position: LatLng(mechanicLat.value!, mechanicLng.value!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Mechanic'),
      ),
    );
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> callMechanic() async {
    final phone = request['mechanicPhone'];
    if (phone == null || phone.isEmpty) {
      Get.snackbar("Error", "Mechanic phone number not available");
      return;
    }

    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", "Cannot make call");
    }
  }

  void openChat() {
    final chatId = request['id'] ?? '';
    if (chatId.isEmpty) {
      Get.snackbar('Error', 'Chat not available yet');
      return;
    }

    Get.delete<ChatController>(force: true);
    Get.put(
      ChatController(
        chatId: chatId,
        otherUserName: request['mechanicName'] ?? 'Mechanic',
        otherUserPhoto: request['mechanicPhoto'] ?? '',
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
    Get.snackbar(
      "Copied!",
      "Verification code copied to clipboard",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  void shareVerificationCode(String code) async {
    final mechanicPhone = request['mechanicPhone'];
    if (mechanicPhone != null) {
      final uri = Uri.parse(
        'sms:$mechanicPhone?body=Your DriveResQ verification code is: $code',
      );
      launchUrl(uri);
    } else {
      // Legacy support for SharePlus syntax found in existing code
      SharePlus.instance.share(
        ShareParams(text: 'Your DriveResQ verification code is: $code'),
      );
    }
  }
}
