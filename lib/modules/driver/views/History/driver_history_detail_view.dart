import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_spacing.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../shared/widgets/history_invoice_viewer.dart';

class DriverHistoryDetailView extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const DriverHistoryDetailView({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final status = requestData['status'] ?? 'unknown';
    final isCompleted = status == 'completed';
    final completionData =
        requestData['completionData'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Request Details',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          if (isCompleted && completionData != null)
            IconButton(
              icon: const Icon(Iconsax.document_download,
                  color: AppColors.primary),
              tooltip: 'Download Invoice',
              onPressed: () =>
                  HistoryInvoiceViewer.viewAndShare(completionData, context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Banner ──
            _buildStatusBanner(isCompleted),
            SizedBox(height: 16.h),

            // ── Request Info Card ──
            _buildInfoCard(),
            SizedBox(height: 16.h),

            // ── Timeline ──
            _buildTimeline(),
            SizedBox(height: 16.h),

            // ── Mechanic Info ──
            if (requestData['mechanicId'] != null) ...[
              _buildMechanicCard(),
              SizedBox(height: 16.h),
            ],

            // ── Completion Details ──
            if (isCompleted && completionData != null) ...[
              _buildServicesCard(completionData),
              SizedBox(height: 16.h),
              _buildCostBreakdown(completionData),
              SizedBox(height: 16.h),
            ],

            // ── Invoice Button ──
            if (isCompleted && completionData != null)
              _buildInvoiceButton(completionData, context),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(bool isCompleted) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? [AppColors.success, AppColors.success.withOpacity(0.8)]
              : [AppColors.error, AppColors.error.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.largeAll,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppRadius.mediumAll,
            ),
            child: Icon(
              isCompleted ? Iconsax.tick_circle : Iconsax.close_circle,
              color: Colors.white,
              size: 28.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? 'Request Completed' : 'Request Cancelled',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isCompleted
                      ? 'You were successfully rescued!'
                      : 'This request was cancelled',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _CardWrapper(
      title: 'Request Information',
      icon: Iconsax.info_circle,
      child: Column(
        children: [
          _InfoRow(
              icon: Iconsax.danger,
              label: 'Problem',
              value: requestData['problem'] ?? 'N/A'),
          _InfoRow(
              icon: Iconsax.car,
              label: 'Vehicle',
              value: requestData['vehicleType'] ?? 'N/A'),
          _InfoRow(
              icon: Iconsax.location,
              label: 'Location',
              value: requestData['locationName'] ?? 'N/A'),
          if (requestData['landmark'] != null &&
              requestData['landmark'].toString().isNotEmpty)
            _InfoRow(
                icon: Iconsax.flag,
                label: 'Landmark',
                value: requestData['landmark']),
          if (requestData['vehicleNumber'] != null &&
              requestData['vehicleNumber'].toString().isNotEmpty)
            _InfoRow(
                icon: Iconsax.hashtag,
                label: 'Vehicle No.',
                value: requestData['vehicleNumber']),
          if (requestData['description'] != null &&
              requestData['description'].toString().isNotEmpty)
            _InfoRow(
                icon: Iconsax.document_text,
                label: 'Description',
                value: requestData['description']),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final createdAt = _formatTimestamp(requestData['createdAt']);
    final acceptedAt = _formatTimestamp(requestData['acceptedAt']);
    final completedAt = _formatTimestamp(requestData['completedAt']);
    final cancelledAt = _formatTimestamp(requestData['cancelledAt']);
    final isCompleted = requestData['status'] == 'completed';

    return _CardWrapper(
      title: 'Timeline',
      icon: Iconsax.timer_1,
      child: Column(
        children: [
          _TimelineStep(
            label: 'Request Created',
            time: createdAt,
            isCompleted: true,
            isFirst: true,
          ),
          if (acceptedAt.isNotEmpty)
            _TimelineStep(
              label: 'Mechanic Accepted',
              time: acceptedAt,
              isCompleted: true,
            ),
          _TimelineStep(
            label: isCompleted ? 'Completed' : 'Cancelled',
            time: isCompleted ? completedAt : cancelledAt,
            isCompleted: true,
            isLast: true,
            color: isCompleted ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildMechanicCard() {
    final mechanicId = requestData['mechanicId'] as String?;
    if (mechanicId == null) return const SizedBox.shrink();

    return _CardWrapper(
      title: 'Mechanic',
      icon: Iconsax.personalcard,
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(mechanicId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Padding(
              padding: EdgeInsets.all(8.w),
              child: Text('Mechanic details unavailable',
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary)),
            );
          }

          final mech = snapshot.data!.data() as Map<String, dynamic>;
          final name = mech['fullName'] ?? mech['name'] ?? 'Mechanic';
          final phone = mech['phone'] ??
              requestData['mechanicPhone'] ??
              '';
          final photo = mech['profilePhotoUrl'] ?? '';

          return Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.mechanicPrimary.withOpacity(0.15),
                backgroundImage:
                    photo.isNotEmpty ? NetworkImage(photo) : null,
                child: photo.isEmpty
                    ? Icon(Iconsax.user, color: AppColors.mechanicPrimary)
                    : null,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: GoogleFonts.poppins(
                            fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    if (phone.isNotEmpty)
                      Text(phone,
                          style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildServicesCard(Map<String, dynamic> data) {
    final services = List<String>.from(data['servicesPerformed'] ?? []);
    if (services.isEmpty) return const SizedBox.shrink();

    return _CardWrapper(
      title: 'Services Performed',
      icon: Iconsax.setting_2,
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: services
            .map((s) => Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: Text(s,
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary)),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCostBreakdown(Map<String, dynamic> data) {
    final baseCharge = (data['baseCharge'] ?? 0).toDouble();
    final laborCharges = (data['laborCharges'] ?? 0).toDouble();
    final partsTotal = (data['partsTotal'] ?? 0).toDouble();
    final travelCost = (data['travelCost'] ?? 0).toDouble();
    final totalAmount = (data['totalAmount'] ?? 0).toDouble();

    return _CardWrapper(
      title: 'Cost Breakdown',
      icon: Iconsax.wallet_2,
      child: Column(
        children: [
          _CostRow(label: 'Base Charge', amount: baseCharge),
          _CostRow(label: 'Labor Charges', amount: laborCharges),
          _CostRow(label: 'Parts Cost', amount: partsTotal),
          _CostRow(label: 'Travel Cost', amount: travelCost),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(color: AppColors.border.withOpacity(0.5)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount',
                  style: GoogleFonts.poppins(
                      fontSize: 16.sp, fontWeight: FontWeight.bold)),
              Text('₹${totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceButton(
      Map<String, dynamic> data, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton.icon(
        onPressed: () => HistoryInvoiceViewer.viewAndShare(data, context),
        icon: const Icon(Iconsax.document_download),
        label: Text('View & Share Invoice',
            style: GoogleFonts.poppins(
                fontSize: 15.sp, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final d = ts.toDate();
      return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }
}

// ═══════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════

class _CardWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _CardWrapper(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
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
        children: [
          Row(
            children: [
              Icon(icon, size: 18.w, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.w, color: AppColors.textHint),
          SizedBox(width: 10.w),
          SizedBox(
            width: 85.w,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final String time;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;
  final Color? color;

  const _TimelineStep({
    required this.label,
    required this.time,
    this.isCompleted = false,
    this.isFirst = false,
    this.isLast = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = color ?? (isCompleted ? AppColors.primary : AppColors.disabled);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24.w,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                      child: Container(
                          width: 2, color: dotColor.withOpacity(0.3))),
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                      child: Container(
                          width: 2, color: dotColor.withOpacity(0.3))),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  if (time.isNotEmpty)
                    Text(time,
                        style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final double amount;

  const _CostRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13.sp, color: AppColors.textSecondary)),
          Text('₹${amount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                  fontSize: 14.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
