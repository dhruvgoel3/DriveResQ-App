import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/verification_controller.dart';
import 'review_helpers.dart';
import 'decision_dialogs.dart';

class ReviewDecisionTab extends StatelessWidget {
  final Map<String, dynamic> mechanicData;
  final VerificationController controller;

  const ReviewDecisionTab({
    super.key,
    required this.mechanicData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final uid = mechanicData['uid'] ?? '';
    final name = mechanicData['fullName'] ?? 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Notes
          ReviewHelpers.buildCard([
            Text(
              'Admin Notes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.adminNotesController,
              maxLines: 4,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add internal notes about this application...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                filled: false,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => controller.saveAdminNotes(uid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save Notes',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Verification Checklist
          ReviewHelpers.buildCard([
            Text(
              'Verification Checklist',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Column(
                children: VerificationController.verificationChecklist.map((
                  item,
                ) {
                  return CheckboxListTile(
                    value: controller.checklist[item] ?? false,
                    onChanged: (v) => controller.checklist[item] = v ?? false,
                    title: Text(item, style: GoogleFonts.poppins(fontSize: 13)),
                    activeColor: const Color(0xFFFF9800),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }).toList(),
              ),
            ),
          ]),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Approve
              SizedBox(
                width: 220,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => DecisionDialogs.showApproveDialog(
                    context,
                    controller,
                    uid,
                    name,
                  ),
                  icon: const Icon(Iconsax.tick_circle, size: 22),
                  label: Text(
                    'Approve Application',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Reject
              SizedBox(
                width: 220,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => DecisionDialogs.showRejectDialog(
                    context,
                    controller,
                    uid,
                    name,
                  ),
                  icon: const Icon(Iconsax.close_square, size: 22),
                  label: Text(
                    'Reject Application',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
