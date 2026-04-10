import 'package:get/get.dart';
import '../controller/mechanic_controller.dart';

class MechanicBinding extends Bindings {
  @override
  void dependencies() {
    /* print stripped */
    Get.lazyPut<MechanicController>(() => MechanicController());
  }
}
