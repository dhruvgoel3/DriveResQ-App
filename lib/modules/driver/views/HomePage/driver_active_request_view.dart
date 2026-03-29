import 'package:flutter/material.dart';

class DriverActiveRequestView extends StatelessWidget {
  final Map<String, dynamic> request;

  const DriverActiveRequestView({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text("Status: ${request['status']}"),
        subtitle: request['status'] == 'accepted'
            ? const Text("A mechanic is on the way 🚗")
            : const Text("Waiting for mechanic"),
      ),
    );
  }
}
