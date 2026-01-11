import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../mechanic/views/create_request_view.dart';

class DriverHomeView extends StatelessWidget {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Dashboard")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => CreateRequestView());
          },
          child: const Text("New Request"),
        ),
      ),
    );
  }
}
