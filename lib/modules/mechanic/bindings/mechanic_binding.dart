import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controller/mechanic_controller.dart';

class MechanicBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint("MechanicBinding executed");
    Get.lazyPut<MechanicController>(() => MechanicController());
  }
}
