import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../shared/widgets/rating_dialog.dart';
import '../../../../shared/services/rating_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/helpers/responsive_helper.dart';
import '../../controllers/driver_controller.dart';

class JobReceiptView extends StatelessWidget {
  final Map<String, dynamic> request;

  const JobReceiptView({super.key, required this.request});

  Future<Map<String, dynamic>?> _fetchCompletedJob() async {
    final doc = await FirebaseFirestore.instance
        .collection('completedJobs')
        .doc(request['id'])
        .get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  void _closeReceipt() async {
    try {
      // Mark as acknowledged / closed so the stream no longer picks it up
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(request['id'])
          .update({'status': 'closed', 'driverArchived': true});
    } catch (e) {
      debugPrint("Error archiving closed job: $e");
    }

    // Immediately clear the driver controller state so UI transitions instantly
    try {
      final driverController = Get.find<DriverController>();
      driverController.hasActiveRequest.value = false;
      driverController.requestData.value = null;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchCompletedJob(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(40.h),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        final job = snapshot.data;

        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 5.h),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Iconsax.tick_circle, color: AppColors.success, size: 48.w),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Job Completed!",
                      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      job?['invoiceNumber'] ?? 'Invoice available',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // MECHANIC INFO
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(Iconsax.user, color: AppColors.primary),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Mechanic", style: AppTextStyles.caption),
                          Text(
                            request['mechanicName'] ?? 'Unknown Mechanic',
                            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // SERVICES PERFORMED
              if (job != null && job['servicesPerformed'] != null) ...[
                Text("Services Performed", style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: (job['servicesPerformed'] as List).map((s) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        s.toString(),
                        style: AppTextStyles.label.copyWith(color: AppColors.primary),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
              ],

              // COST BREAKDOWN
              Text("Cost Breakdown", style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(height: 12.h),
              if (job != null) ...[
                _costRow('Base Service Charge', (job['baseCharge'] as num?)?.toDouble() ?? 0),
                if ((job['laborCharges'] as num?) != null && job['laborCharges'] > 0)
                  _costRow('Labor Charges', (job['laborCharges'] as num).toDouble()),
                if ((job['partsTotal'] as num?) != null && job['partsTotal'] > 0)
                  _costRow('Parts Cost', (job['partsTotal'] as num).toDouble()),
                if ((job['travelCost'] as num?) != null && job['travelCost'] > 0)
                  _costRow('Travel Cost', (job['travelCost'] as num).toDouble()),
                Divider(color: AppColors.border, height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Amount", style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      "₹${((job['totalAmount'] as num?)?.toDouble() ?? request['totalAmount'] ?? 0).toStringAsFixed(0)}",
                      style: AppTextStyles.h2.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Amount", style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      "₹${(request['totalAmount'] ?? 0).toStringAsFixed(0)}",
                      style: AppTextStyles.h2.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 32.h),

              // ACTION BUTTONS
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _closeReceipt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Return to Dashboard",
                    style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // RATE MECHANIC BUTTON
              if (request['mechanicId'] != null)
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: OutlinedButton(
                    onPressed: () => _showRatingDialog(context, request['mechanicId'], request['mechanicName'] ?? 'Mechanic'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      "Review Mechanic",
                      style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, String mechanicId, String mechanicName) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        title: 'Rate Mechanic',
        entityName: mechanicName,
        onSubmit: (rating, review) async {
          Get.back(); // close dialog
          Get.snackbar(
            'Submitting...',
            'Saving your review',
            snackPosition: SnackPosition.BOTTOM,
          );
          
          try {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              await RatingService.submitRating(
                targetUserId: mechanicId,
                newRating: rating,
                reviewerId: currentUser.uid,
                reviewText: review,
              );
              Get.snackbar(
                'Success',
                'Thank you for your feedback!',
                backgroundColor: AppColors.success.withOpacity(0.1),
                colorText: AppColors.success,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to submit review',
              backgroundColor: AppColors.error.withOpacity(0.1),
              colorText: AppColors.error,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
      ),
    );
  }

  Widget _costRow(String label, double amount) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
          Text("₹${amount.toStringAsFixed(0)}", style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
