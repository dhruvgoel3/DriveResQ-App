import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_spacing.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../shared/widgets/history_invoice_viewer.dart';

class MechanicHistoryDetailView extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const MechanicHistoryDetailView({super.key, required this.requestData});

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
        title: Text(
          'Job Details',
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isCompleted && completionData != null)
            IconButton(
              icon: const Icon(
                Iconsax.document_download,
                color: AppColors.mechanicPrimary,
              ),
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

            // ── Job Info Card ──
            _buildJobInfoCard(),
            SizedBox(height: 16.h),

            // ── Driver Info ──
            _buildDriverCard(),
            SizedBox(height: 16.h),

            // ── Timeline ──
            _buildTimeline(),
            SizedBox(height: 16.h),

            // ── Completion Details ──
            if (isCompleted && completionData != null) ...[
              _buildServicesCard(completionData),
              SizedBox(height: 16.h),
              _buildCostBreakdown(completionData),
              SizedBox(height: 16.h),

              // ── Driver Rating (given by mechanic) ──
              if (completionData['driverRating'] != null &&
                  (completionData['driverRating'] as num) > 0)
                _buildRatingCard(completionData),
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
                  isCompleted ? 'Job Completed' : 'Job Cancelled',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isCompleted
                      ? 'Great work! Job was completed successfully.'
                      : 'This job was cancelled',
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

  Widget _buildJobInfoCard() {
    return _CardWrapper(
      title: 'Job Information',
      icon: Iconsax.info_circle,
      child: Column(
        children: [
          _InfoRow(
            icon: Iconsax.danger,
            label: 'Problem',
            value: requestData['problem'] ?? 'N/A',
          ),
          _InfoRow(
            icon: Iconsax.car,
            label: 'Vehicle',
            value: requestData['vehicleType'] ?? 'N/A',
          ),
          _InfoRow(
            icon: Iconsax.location,
            label: 'Location',
            value: requestData['locationName'] ?? 'N/A',
          ),
          if (requestData['landmark'] != null &&
              requestData['landmark'].toString().isNotEmpty)
            _InfoRow(
              icon: Iconsax.flag,
              label: 'Landmark',
              value: requestData['landmark'],
            ),
          if (requestData['vehicleNumber'] != null &&
              requestData['vehicleNumber'].toString().isNotEmpty)
            _InfoRow(
              icon: Iconsax.hashtag,
              label: 'Vehicle No.',
              value: requestData['vehicleNumber'],
            ),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    final driverId = requestData['driverId'] as String?;
    if (driverId == null) return const SizedBox.shrink();

    return _CardWrapper(
      title: 'Driver',
      icon: Iconsax.personalcard,
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(driverId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                'Driver details unavailable',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          final driver = snapshot.data!.data() as Map<String, dynamic>;
          final name = driver['fullName'] ?? driver['name'] ?? 'Driver';
          final phone = driver['phone'] ?? requestData['driverPhone'] ?? '';
          final photo = driver['profilePhotoUrl'] ?? '';
          final rating = (driver['averageRating'] ?? 0.0).toDouble();

          return Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                backgroundImage: photo.isNotEmpty ? CachedNetworkImageProvider(photo) : null,
                child: photo.isEmpty
                    ? const Icon(Iconsax.user, color: AppColors.primary)
                    : null,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (rating > 0) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.star1,
                                  color: AppColors.warning,
                                  size: 12.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (phone.isNotEmpty)
                      Text(
                        phone,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
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
          _TimelineStep(
            label: 'You Accepted',
            time: acceptedAt,
            isCompleted: acceptedAt.isNotEmpty,
          ),
          _TimelineStep(
            label: isCompleted ? 'Job Completed' : 'Job Cancelled',
            time: isCompleted ? completedAt : cancelledAt,
            isCompleted: true,
            isLast: true,
            color: isCompleted ? AppColors.success : AppColors.error,
          ),
        ],
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
            .map(
              (s) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.mechanicPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.mechanicPrimary.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  s,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mechanicPrimary,
                  ),
                ),
              ),
            )
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
      title: 'Earnings Breakdown',
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
              Text(
                'Total Earned',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> data) {
    final rating = (data['driverRating'] ?? 0).toDouble();
    final review = data['driverReview'] ?? '';
    final tags = List<String>.from(data['driverTags'] ?? []);

    return _CardWrapper(
      title: 'Your Rating of Driver',
      icon: Iconsax.star,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < rating.round() ? Iconsax.star1 : Iconsax.star,
                size: 24.w,
                color: AppColors.warning,
              );
            }),
          ),
          if (tags.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: tags
                  .map(
                    (t) => Chip(
                      label: Text(
                        t,
                        style: GoogleFonts.poppins(fontSize: 11.sp),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (review.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              review,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceButton(Map<String, dynamic> data, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton.icon(
        onPressed: () => HistoryInvoiceViewer.viewAndShare(data, context),
        icon: const Icon(Iconsax.document_download),
        label: Text(
          'View & Share Invoice',
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mechanicPrimary,
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

  const _CardWrapper({
    required this.title,
    required this.icon,
    required this.child,
  });

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
              Icon(icon, size: 18.w, color: AppColors.mechanicPrimary),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
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

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
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
    final dotColor =
        color ?? (isCompleted ? AppColors.mechanicPrimary : AppColors.disabled);
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
                      width: 2,
                      color: dotColor.withOpacity(0.3),
                    ),
                  ),
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
                      width: 2,
                      color: dotColor.withOpacity(0.3),
                    ),
                  ),
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
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
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
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
