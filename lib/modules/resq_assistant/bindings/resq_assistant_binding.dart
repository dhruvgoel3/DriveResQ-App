import 'package:get/get.dart';

import '../controllers/resq_assistant_controller.dart';
import '../services/resq_assistant_service.dart';

class ResQAssistantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResQAssistantService>(() => ResQAssistantService());
    Get.lazyPut<ResQAssistantController>(
      () => ResQAssistantController(service: Get.find<ResQAssistantService>()),
    );
  }
}
