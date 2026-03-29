import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewHelpers {
  static Widget buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  static Widget buildField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 160, child: Text(label, style: labelStyle())),
          Expanded(
            child: Text(
              '${value ?? 'N/A'}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSecureField(
    String label,
    dynamic value, {
    bool mask = false,
  }) {
    String display = '${value ?? 'N/A'}';
    if (mask && display.length > 4) {
      display =
          '${'•' * (display.length - 4)}${display.substring(display.length - 4)}';
    }
    return buildField(label, display);
  }

  static TextStyle labelStyle() {
    return GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade500,
    );
  }
}
