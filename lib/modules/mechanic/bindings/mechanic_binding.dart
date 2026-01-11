import 'package:get/get.dart';

import '../controller/mechanic_controller.dart';


class MechanicBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MechanicController());
  }
}
