import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../controllers/auth_controller.dart';

class RoleSelectionView extends StatelessWidget {
  final AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => controller.saveRole('driver'),
            child: Text("I am a Driver"),
          ),
          ElevatedButton(
            onPressed: () => controller.saveRole('mechanic'),
            child: Text("I am a Mechanic"),
          ),
        ],
      ),
    );
  }
}
