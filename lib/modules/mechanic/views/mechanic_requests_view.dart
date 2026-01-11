import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../auth/controllers/auth_controller.dart';

class MechanicRequestsView extends StatelessWidget {
  const MechanicRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mechanic Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("Switch Role"),
                  content: const Text("Switch to Driver Dashboard?"),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.find<AuthController>().switchRole('driver');
                      },
                      child: const Text("Switch"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: const Center(child: Text("Requests will appear here (Module 3)")),
    );
  }
}
