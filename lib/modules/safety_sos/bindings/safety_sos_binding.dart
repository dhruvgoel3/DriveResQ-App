import 'package:get/get.dart';
import '../controllers/safety_sos_controller.dart';

class SafetySosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SafetySosController>(() => SafetySosController());
  }
}
