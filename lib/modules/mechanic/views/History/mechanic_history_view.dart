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
import '../../controllers/mechanic_history_controller.dart';
import 'mechanic_history_detail_view.dart';

class MechanicHistoryView extends StatelessWidget {
  const MechanicHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MechanicHistoryController());

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
          'Job History',
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.mechanicPrimary),
          );
        }

        if (controller.historyList.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchHistory,
          color: AppColors.mechanicPrimary,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _buildStatsGrid(controller),
              SizedBox(height: 20.h),
              Text(
                'Past Jobs',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              ...controller.historyList
                  .map(
                    (item) => _HistoryJobCard(
                      data: item,
                      onTap: () => Get.to(
                        () => MechanicHistoryDetailView(requestData: item),
                        transition: Transition.rightToLeft,
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.mechanicPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.clock,
              size: 64.w,
              color: AppColors.mechanicPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No History Yet',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your completed jobs will appear here',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(MechanicHistoryController controller) {
    return Column(
      children: [
        Row(
          children: [
            _StatCard(
              icon: Iconsax.briefcase,
              label: 'Total Jobs',
              value: controller.totalJobs.value.toString(),
              color: AppColors.mechanicPrimary,
            ),
            SizedBox(width: 12.w),
            _StatCard(
              icon: Iconsax.tick_circle,
              label: 'Completed',
              value: controller.completedJobs.value.toString(),
              color: AppColors.success,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _StatCard(
              icon: Iconsax.wallet_2,
              label: 'Earnings',
              value: '₹${controller.totalEarnings.value.toStringAsFixed(0)}',
              color: AppColors.info,
            ),
            SizedBox(width: 12.w),
            _StatCard(
              icon: Iconsax.routing,
              label: 'Distance',
              value: '${controller.totalDistance.value.toStringAsFixed(1)} km',
              color: AppColors.accent,
            ),
          ],
        ),
      ],
    );
  }
}

/// ── Stats card ──
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: AppRadius.largeAll,
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: AppRadius.mediumAll,
              ),
              child: Icon(icon, color: color, size: 22.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Single history item card ──
class _HistoryJobCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _HistoryJobCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'unknown';
    final isCompleted = status == 'completed';
    final problem = data['problem'] ?? 'N/A';
    final vehicleType = data['vehicleType'] ?? '';
    final location = data['locationName'] ?? '';
    final driverName = data['driverName'] ?? 'Driver';
    final totalAmount = data['totalAmount'];
    final createdAt = data['createdAt'];

    String dateStr = '';
    if (createdAt is Timestamp) {
      final d = createdAt.toDate();
      dateStr =
          '${d.day}/${d.month}/${d.year} • ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
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
            // Status + Date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted
                            ? Iconsax.tick_circle
                            : Iconsax.close_circle,
                        size: 14.w,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isCompleted ? 'Completed' : 'Cancelled',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                if (dateStr.isNotEmpty)
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.textHint,
                    ),
                  ),
              ],
            ),

            SizedBox(height: 12.h),

            // Problem + Driver name
            Text(
              problem,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 6.h),

            // Driver name
            Row(
              children: [
                Icon(Iconsax.user, size: 14.w, color: AppColors.textHint),
                SizedBox(width: 4.w),
                Text(
                  'Driver: $driverName',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            // Info chips
            Row(
              children: [
                if (vehicleType.isNotEmpty) ...[
                  Icon(Iconsax.car, size: 14.w, color: AppColors.textHint),
                  SizedBox(width: 4.w),
                  Text(
                    vehicleType,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
                if (location.isNotEmpty) ...[
                  Icon(Iconsax.location, size: 14.w, color: AppColors.textHint),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      location,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // Earnings
            if (isCompleted && totalAmount != null) ...[
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Earned',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '₹${(totalAmount as num).toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],

            // Tap indicator and Invoice
            if (isCompleted && data['completionData'] != null) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: () => HistoryInvoiceViewer.viewAndShare(
                    data['completionData'],
                    context,
                  ),
                  icon: Icon(Iconsax.document_download, size: 18.sp),
                  label: Text(
                    'View Invoice',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mechanicPrimary,
                    side: BorderSide(
                      color: AppColors.mechanicPrimary.withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mechanicPrimary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 14.w,
                    color: AppColors.mechanicPrimary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
