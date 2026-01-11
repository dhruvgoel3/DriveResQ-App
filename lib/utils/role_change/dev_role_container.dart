import 'package:get/get.dart';

class DevRoleController extends GetxController {
  RxString? overrideRole;

  void switchToDriver() {
    overrideRole = 'driver'.obs;
    update();
  }

  void switchToMechanic() {
    overrideRole = 'mechanic'.obs;
    update();
  }

  void clearOverride() {
    overrideRole = null;
    update();
  }

  String? get currentRole => overrideRole?.value;
}
  