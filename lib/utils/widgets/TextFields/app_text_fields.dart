import 'package:flutter/material.dart';

import 'app_input_decoration.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isRequired;
  final int maxLines;
  final TextInputType keyboardType;

  AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isRequired = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: AppInputDecoration(
        label: isRequired ? "$label *" : label,
        icon: icon,
      ),
    );
  }
}
