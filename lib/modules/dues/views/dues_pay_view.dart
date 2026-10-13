import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:driveresq_app/app/routes/app_pages.dart';
import 'package:driveresq_app/modules/auth/controllers/auth_controller.dart';
import 'package:driveresq_app/modules/dues/controllers/dues_controller.dart';
import 'package:driveresq_app/modules/dues/models/platform_due.dart';
import 'package:driveresq_app/modules/dues/services/dues_service.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class DuesPayView extends StatelessWidget {
  const DuesPayView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DuesController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Platform Dues',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Get.back(),
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Sync Dues',
            icon: const Icon(Iconsax.refresh, color: Colors.black87),
            onPressed: controller.refreshDues,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Iconsax.logout, color: Colors.black54),
            onPressed: () {
              if (Get.isRegistered<AuthController>()) {
                Get.find<AuthController>().signOut();
              } else {
                Get.offAllNamed(Routes.LOGIN);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF9800)),
          );
        }

        final outstanding = controller.outstanding.value;
        final isSuspended = controller.isSuspended;
        final dues = controller.duesList;

        return RefreshIndicator(
          color: const Color(0xFFFF9800),
          onRefresh: () async {
            await DuesService.syncPendingDues();
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Suspension alert banner
                if (isSuspended) ...[
                  _buildSuspensionBanner(),
                  SizedBox(height: 16.h),
                ],

                // Outstanding amount summary card
                _buildOutstandingSummaryCard(context, controller, outstanding),
                SizedBox(height: 20.h),

                // Pay Now Button
                _buildPayButton(context, controller, outstanding),
                SizedBox(height: 24.h),

                // Platform fee clarification note
                _buildPolicyInfoBox(),
                SizedBox(height: 24.h),

                // Dues breakdown header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dues Ledger',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${dues.length} total',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Dues list
                if (dues.isEmpty)
                  _buildEmptyState()
                else
                  ...dues.map((due) => _buildDueItemCard(due)),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSuspensionBanner() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.warning_2,
            color: const Color(0xFFE65100),
            size: 22.w,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Paused',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE65100),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'You cannot receive or accept new roadside assistance requests until unpaid platform dues are cleared via Razorpay.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    color: const Color(0xFFBF360C),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingSummaryCard(
    BuildContext context,
    DuesController controller,
    double outstanding,
  ) {
    final bool hasDues = outstanding > 0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasDues
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: (hasDues ? Colors.black : Colors.green)
                .withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Outstanding Dues',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: hasDues
                      ? const Color(0xFFFF9800).withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: hasDues
                        ? const Color(0xFFFFB74D)
                        : Colors.white.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  hasDues ? 'Payment Required' : 'All Settled',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: hasDues ? const Color(0xFFFFB74D) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '₹${outstanding.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            hasDues
                ? 'Calculated from cash-settled labor charges owed to platform.'
                : 'No pending dues. Your account is in good standing!',
            style: GoogleFonts.poppins(
              fontSize: 11.5.sp,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(
    BuildContext context,
    DuesController controller,
    double outstanding,
  ) {
    final bool hasDues = outstanding > 0;
    final bool isPaying = controller.isPaying.value;

    return SizedBox(
      height: 54.h,
      child: ElevatedButton(
        onPressed: (hasDues && !isPaying) ? controller.payOutstanding : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasDues ? const Color(0xFFFF9800) : Colors.grey.shade400,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          elevation: hasDues ? 2 : 0,
          shadowColor: const Color(0xFFFF9800).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: isPaying
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Opening Razorpay...',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.card_tick, size: 20.w),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        hasDues
                            ? 'Pay ₹${outstanding.toStringAsFixed(2)} with Razorpay'
                            : 'No Dues Pending',
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPolicyInfoBox() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.info_circle, size: 18.w, color: Colors.blueGrey),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'DriveResQ platform commission applies ONLY to labor charges collected in cash. Parts, travel compensation, and base charges stay 100% with you.',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.blueGrey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Iconsax.receipt_item, size: 40.w, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            'No Dues Recorded',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Completed cash jobs with labor charges will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5.sp,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueItemCard(PlatformDue due) {
    final isPaid = due.isPaid;
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(due.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isPaid ? Colors.grey.shade200 : const Color(0xFFFFCC80),
          width: isPaid ? 0.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isPaid ? Iconsax.tick_circle : Iconsax.clock,
                      size: 16.w,
                      color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        due.invoiceNumber.isNotEmpty
                            ? 'Invoice #${due.invoiceNumber}'
                            : 'Job #${due.jobId.length > 8 ? due.jobId.substring(0, 8) : due.jobId}',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'UNPAID',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isPaid
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Labor: ₹${due.laborCharges.toStringAsFixed(2)} (${due.commissionPercent.toStringAsFixed(0)}% fee)',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Due: ₹${due.amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isPaid
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            dateStr,
            style: GoogleFonts.poppins(
              fontSize: 10.5.sp,
              color: Colors.black38,
            ),
          ),
          if (due.razorpayPaymentId != null && due.razorpayPaymentId!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              'Payment ID: ${due.razorpayPaymentId}',
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.blueGrey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
