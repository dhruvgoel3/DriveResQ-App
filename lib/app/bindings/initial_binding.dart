import 'package:get/get.dart';

import '../../utils/role_change/dev_role_container.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DevRoleController(), permanent: true);
  }
}
