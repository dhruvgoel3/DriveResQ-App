import 'package:get/get.dart';
import 'package:driveresq_app/modules/dues/controllers/dues_controller.dart';

class DuesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DuesController>(() => DuesController());
  }
}
