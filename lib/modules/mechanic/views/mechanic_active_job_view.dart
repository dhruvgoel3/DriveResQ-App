import 'package:flutter/material.dart';

class MechanicActiveJobView extends StatelessWidget {
  const MechanicActiveJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Active Job")),
      body: const Center(
        child: Text("Active job details will appear here"),
      ),
    );
  }
}
