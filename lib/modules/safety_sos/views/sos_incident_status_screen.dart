import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/helpers/responsive_helper.dart';
import '../controllers/safety_sos_controller.dart';
import '../models/sos_incident_model.dart';
import '../services/sos_live_location_service.dart';

/// Displays the current SOS incident status and per-contact delivery records.
class SosIncidentStatusScreen extends StatelessWidget {
  const SosIncidentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SafetySosController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'SOS Incident Status',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final incident = controller.currentIncident.value;

        if (controller.isDispatching.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 20.h),
                Text(
                  'Sending emergency alerts…',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please keep the app open.',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (incident == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.shield_slash, size: 56.w, color: AppColors.textHint),
                SizedBox(height: 16.h),
                Text(
                  'No active SOS incident.',
                  style: GoogleFonts.inter(fontSize: 16.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IncidentHeader(incident: incident),
              SizedBox(height: 16.h),
              _LiveTrackingCard(incident: incident, controller: controller),
              SizedBox(height: 16.h),
              _LocationCard(incident: incident),
              SizedBox(height: 16.h),
              _DeliveryList(incident: incident),
              SizedBox(height: 16.h),
              _MessageCard(incident: incident),
              SizedBox(height: 20.h),
              _buildResolveButton(context, controller, incident),
              SizedBox(height: 20.h),
              _buildNote(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildResolveButton(
    BuildContext context,
    SafetySosController controller,
    SosIncident incident,
  ) {
    final isBroadcasting = incident.isLiveTrackingActive;

    if (!isBroadcasting && incident.status == SosIncidentStatus.resolved) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          children: [
            Icon(Iconsax.shield_tick, color: const Color(0xFF059669), size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Incident Resolved & Marked Safe',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF065F46),
                    ),
                  ),
                  Text(
                    'Live GPS broadcast has been stopped. Emergency contacts viewing the tracker link see that you are safe.',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: () => _confirmMarkSafe(context, controller),
        icon: const Icon(Iconsax.shield_tick, color: Colors.white),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'I am Safe — Stop Live GPS Tracking',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF059669),
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }

  void _confirmMarkSafe(BuildContext context, SafetySosController controller) {
    Get.defaultDialog(
      title: 'Confirm You Are Safe',
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16.sp),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Text(
          'This will stop real-time GPS broadcasting and update the emergency tracking status to resolved. Are you safe?',
          style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ),
      textConfirm: 'Yes, I am Safe',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF059669),
      cancelTextColor: AppColors.textSecondary,
      onConfirm: () async {
        Get.back();
        await controller.resolveAndStopTracking();
      },
    );
  }

  Widget _buildNote() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFECB6A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18.w, color: const Color(0xFFB45309)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Messages marked "Action Required" were opened in WhatsApp or SMS, '
              'but require you to press Send. DriveResQ cannot send automatically '
              'without a server-side SMS provider.',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF92400E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _IncidentHeader extends StatelessWidget {
  final SosIncident incident;
  const _IncidentHeader({required this.incident});

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(incident.status);
    final statusColor = _statusColor(incident.status);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.sos, size: 24.w, color: const Color(0xFFDC2626)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency SOS',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'ID: ${incident.id.length > 8 ? incident.id.substring(0, 8).toUpperCase() : incident.id.toUpperCase()}…',
                      style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20.h, color: AppColors.border),
          _row('Created', DateFormat('dd MMM yyyy, hh:mm a').format(incident.createdAt)),
          SizedBox(height: 4.h),
          _row('Trigger', incident.triggerType == SosTriggerType.shake ? 'Shake' : 'Manual'),
          SizedBox(height: 4.h),
          _row('Help Request', incident.helpRequestId),
          if (incident.mechanicId != null) ...[
            SizedBox(height: 4.h),
            _row('Mechanic ID', incident.mechanicId!),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _statusLabel(SosIncidentStatus s) {
    switch (s) {
      case SosIncidentStatus.created:
        return 'Created';
      case SosIncidentStatus.locationPending:
        return 'Getting Location';
      case SosIncidentStatus.dispatching:
        return 'Dispatching';
      case SosIncidentStatus.partiallySent:
        return 'Action Required';
      case SosIncidentStatus.sent:
        return 'Sent';
      case SosIncidentStatus.resolved:
        return 'Resolved / Safe';
      case SosIncidentStatus.failed:
        return 'Failed';
      case SosIncidentStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _statusColor(SosIncidentStatus s) {
    switch (s) {
      case SosIncidentStatus.sent:
        return const Color(0xFF059669);
      case SosIncidentStatus.resolved:
        return const Color(0xFF10B981);
      case SosIncidentStatus.failed:
        return const Color(0xFFDC2626);
      case SosIncidentStatus.cancelled:
        return AppColors.textHint;
      default:
        return const Color(0xFFD97706);
    }
  }
}

class _LiveTrackingCard extends StatelessWidget {
  final SosIncident incident;
  final SafetySosController controller;

  const _LiveTrackingCard({
    required this.incident,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final trackingUrl = incident.liveTrackingUrl ??
        SosLiveLocationService.buildLiveTrackingUrl(incident.id);
    final isBroadcasting = incident.isLiveTrackingActive;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isBroadcasting ? const Color(0xFFFEF2F2) : AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isBroadcasting ? const Color(0xFFFCA5A5) : AppColors.border,
          width: isBroadcasting ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isBroadcasting ? Colors.red : Colors.black).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isBroadcasting ? const Color(0xFFEF4444) : AppColors.textHint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.satellite_alt_rounded, size: 18, color: Colors.white),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live GPS Real-Time Tracker',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isBroadcasting
                          ? 'Continuous real-time satellite broadcast active'
                          : 'Live broadcast ended / Safe',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: isBroadcasting ? const Color(0xFFB91C1C) : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isBroadcasting
                      ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: isBroadcasting ? const Color(0xFFDC2626) : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      isBroadcasting ? 'LIVE' : 'OFFLINE',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: isBroadcasting ? const Color(0xFFDC2626) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.link_rounded, size: 16.w, color: AppColors.primary),
                    SizedBox(width: 6.w),
                    Text(
                      'Emergency Contact Live Tracker Link:',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                SelectableText(
                  trackingUrl,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: trackingUrl));
                    Get.snackbar(
                      'Link Copied',
                      'Live tracking link copied to clipboard.',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  icon: Icon(Icons.copy, size: 16.w, color: AppColors.primary),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Copy Link',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(trackingUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_browser, size: 16, color: Colors.white),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Preview Map',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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

class _LocationCard extends StatelessWidget {
  final SosIncident incident;
  const _LocationCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final hasLoc = incident.latitude != null && incident.longitude != null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.location5, size: 18.w, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Location',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (hasLoc) ...[
            Text(
              '${incident.latitude!.toStringAsFixed(5)}, ${incident.longitude!.toStringAsFixed(5)}',
              style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            if (incident.locationAccuracy != null)
              Text(
                'Accuracy: ±${incident.locationAccuracy!.toStringAsFixed(0)} m',
                style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textHint),
              ),
            if (incident.locationCapturedAt != null)
              Text(
                'Captured: ${DateFormat('hh:mm:ss a').format(incident.locationCapturedAt!)}',
                style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textHint),
              ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.location_off, size: 16.w, color: AppColors.textHint),
                SizedBox(width: 6.w),
                Text(
                  'Location not available.',
                  style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryList extends StatelessWidget {
  final SosIncident incident;
  const _DeliveryList({required this.incident});

  @override
  Widget build(BuildContext context) {
    final records = incident.deliveryRecords;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.people, size: 18.w, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Emergency Contacts (${records.length})',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (records.isEmpty)
            Text(
              'No contacts were processed.',
              style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textSecondary),
            )
          else
            ...records.map((r) => _ContactRow(record: r)),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final ContactDeliveryRecord record;
  const _ContactRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = _color(record.status);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon(record.status), size: 16.w, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.contactName,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  record.contactPhone,
                  style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textHint),
                ),
                if (record.note != null)
                  Text(
                    record.note!,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              _label(record.status),
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(String s) {
    switch (s) {
      case 'fallback_required':
        return Icons.open_in_new;
      case 'skipped':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }

  Color _color(String s) {
    switch (s) {
      case 'fallback_required':
        return const Color(0xFFD97706);
      case 'skipped':
        return const Color(0xFFDC2626);
      default:
        return AppColors.textHint;
    }
  }

  String _label(String s) {
    switch (s) {
      case 'fallback_required':
        return 'Action Required';
      case 'skipped':
        return 'Not Sent';
      default:
        return 'Pending';
    }
  }
}

class _MessageCard extends StatelessWidget {
  final SosIncident incident;
  const _MessageCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.message_text, size: 18.w, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Message Sent',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              incident.message,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
