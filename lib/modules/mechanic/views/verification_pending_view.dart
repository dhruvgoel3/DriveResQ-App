import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class VerificationPendingView extends StatelessWidget {
  const VerificationPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final status = data?['verificationStatus'] ?? 'pending';

              if (status == 'approved') {
                // Auto-navigate to dashboard with a tiny delay to ensure stability
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (Get.currentRoute == '/mechanic-verification') {
                    Get.offAllNamed('/mechanic');
                  }
                });
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF9800)),
                );
              }

              if (status == 'rejected') {
                return _buildRejectedView(
                  data?['rejectionReason'] ?? 'No reason provided',
                );
              }
            }

            String currentStatus = 'loading';
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              currentStatus = data?['verificationStatus'] ?? 'pending';
            }

            return _buildPendingView(status: currentStatus, snapshot: snapshot);
          },
        ),
      ),
    );
  }

  Future<void> _checkStatusManually() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final status = doc.data()?['verificationStatus'];
        if (status == 'approved') {
          Get.offAllNamed('/mechanic');
        } else {
          Get.snackbar(
            'Status: $status',
            'Your account is still being reviewed. Please wait or contact support.',
            backgroundColor: Colors.white,
            colorText: Colors.black87,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      debugPrint('Error manually checking status: $e');
    }
  }

  Widget _buildPendingView({
    required String status,
    required AsyncSnapshot<DocumentSnapshot> snapshot,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
      child: Column(
        children: [
          // Animated clock illustration
          Container(
            width: 140.w,
            height: 140.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF9800).withOpacity(0.1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF9800).withOpacity(0.15),
                  ),
                ),
                Icon(Iconsax.timer, size: 56.w, color: const Color(0xFFFF9800)),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          Text(
            'Verification In Progress',
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 12.h),

          Text(
            'Your application has been submitted successfully. Our team is reviewing your documents and will verify your account shortly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              height: 1.6,
              color: Colors.grey.shade500,
            ),
          ),

          SizedBox(height: 28.h),

          // Status steps
          _statusStep('Application Submitted', true),
          _statusStep('Document Verification', false, subtitle: 'In Progress'),
          _statusStep('Account Activation', false),

          SizedBox(height: 28.h),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: _checkStatusManually,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'Refresh My Status',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 32.h),

          // Debug section (collapsed by default)
          ExpansionTile(
            title: Text(
              'View Debug Info',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                color: Colors.grey.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _debugRow(
                      'Your UID:',
                      FirebaseAuth.instance.currentUser?.uid ?? 'No User',
                    ),
                    _debugRow('Status:', status),
                    _debugRow(
                      'Exists:',
                      (snapshot.hasData && snapshot.data != null)
                          ? snapshot.data!.exists.toString()
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Logout button
          TextButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.deleteAll(force: true);
              Get.offAllNamed('/role');
            },
            icon: Icon(Iconsax.logout, color: Colors.grey, size: 20.w),
            label: Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _statusStep(String title, bool completed, {String? subtitle}) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? Color(0xFF4CAF50) : Colors.grey.shade200,
                  border: Border.all(
                    color: completed ? Color(0xFF4CAF50) : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: completed
                    ? Icon(Iconsax.tick_circle, size: 16.w, color: Colors.white)
                    : null,
              ),
              Container(
                width: 2,
                height: 24.h,
                color: completed ? Color(0xFF4CAF50) : Colors.grey.shade200,
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: completed ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedView(String reason) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
      child: Column(
        children: [
          Container(
            width: 140.w,
            height: 140.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade50,
            ),
            child: Icon(
              Iconsax.close_circle,
              size: 64.w,
              color: Colors.red.shade400,
            ),
          ),

          SizedBox(height: 32.h),

          Text(
            'Verification Rejected',
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            'Unfortunately, your application could not be verified. Please review the reason below and resubmit.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              height: 1.6,
              color: Colors.grey.shade500,
            ),
          ),

          SizedBox(height: 24.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason for Rejection',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  reason,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.red.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {
                // Reset onboarding and navigate back
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .update({
                      'onboardingCompleted': false,
                      'verificationStatus': '',
                    });
                Get.offAllNamed('/mechanic-onboarding');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9800),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'Resubmit Application',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          TextButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.deleteAll(force: true);
              Get.offAllNamed('/role');
            },
            icon: Icon(Iconsax.logout, color: Colors.grey, size: 20.w),
            label: Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
