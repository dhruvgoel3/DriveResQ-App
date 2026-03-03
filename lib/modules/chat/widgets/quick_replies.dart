import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickRepliesBar extends StatelessWidget {
  final List<String> replies;
  final void Function(String) onTap;

  const QuickRepliesBar({
    super.key,
    required this.replies,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: replies
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(
                      r,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    backgroundColor: const Color(0xFF6C63FF).withOpacity(0.08),
                    side: BorderSide(
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => onTap(r),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
