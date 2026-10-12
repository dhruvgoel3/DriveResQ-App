import 'package:get/get.dart';
import '../controllers/mechanic_controller.dart';

class MechanicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MechanicController>(() => MechanicController());
  }
}
