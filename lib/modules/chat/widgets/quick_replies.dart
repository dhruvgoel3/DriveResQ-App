import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class QuickRepliesBar extends StatelessWidget {
  final List<String> replies;
  final void Function(String) onTap;


  QuickRepliesBar({
    super.key,
    required this.replies,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
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
                  padding: EdgeInsets.only(right: 6.w),
                  child: ActionChip(
                    label: Text(
                      r,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    backgroundColor: Color(0xFF6C63FF).withOpacity(0.08),
                    side: BorderSide(
                      color: Color(0xFF6C63FF).withOpacity(0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
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
