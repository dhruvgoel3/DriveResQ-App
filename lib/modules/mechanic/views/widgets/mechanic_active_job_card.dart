import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../chat/controllers/chat_controller.dart';
import '../../../chat/views/chat_screen.dart';
import 'complete_job_verification_dialog.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class MechanicActiveJobCard extends StatefulWidget {
  final Map<String, dynamic> job;
  final bool isActive;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;
  final int animationIndex;

  const MechanicActiveJobCard({
    super.key,
    required this.job,
    this.isActive = false,
    this.onAccept,
    this.onCancel,
    this.animationIndex = 0,
  });

  @override
  State<MechanicActiveJobCard> createState() => _MechanicActiveJobCardState();
}

class _MechanicActiveJobCardState extends State<MechanicActiveJobCard>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF6C63FF);
  static const _orange = Color(0xFFFF9800);
  static const _green = Color(0xFF4CAF50);
  static const _red = Color(0xFFF44336);

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.animationIndex * 100), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _isUrgent {
    final createdAt = widget.job['createdAt'];
    if (createdAt == null) return false;
    try {
      final ts = createdAt.toDate() as DateTime;
      return DateTime.now().difference(ts).inMinutes > 30;
    } catch (_) {
      return false;
    }
  }

  bool get _isVeryClose {
    final d = widget.job['distance'];
    if (d == null) return false;
    try {
      return double.parse(d.toString()) < 5;
    } catch (_) {
      return false;
    }
  }

  String get _timeAgo {
    final createdAt = widget.job['createdAt'];
    if (createdAt == null) return '';
    try {
      final ts = createdAt.toDate() as DateTime;
      final diff = DateTime.now().difference(ts);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  IconData _problemIcon(String? problem) {
    final p = (problem ?? '').toLowerCase();
    if (p.contains('tire') || p.contains('tyre') || p.contains('flat')) {
      return Icons.car_repair;
    }
    if (p.contains('engine') || p.contains('motor')) return Icons.build;
    if (p.contains('battery') || p.contains('charge')) {
      return Icons.battery_charging_full;
    }
    if (p.contains('fuel') || p.contains('petrol') || p.contains('diesel')) {
      return Icons.local_gas_station;
    }
    if (p.contains('key') || p.contains('lock')) return Icons.vpn_key;
    return Icons.warning_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: _isUrgent && !widget.isActive
                ? Border.all(color: _red.withOpacity(0.5), width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProblemSection(),
                    SizedBox(height: 14.h),
                    _buildDriverInfo(),
                    if (widget.job['description'] != null &&
                        widget.job['description'].toString().isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _buildDescription(),
                    ],
                    if (_timeAgo.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _buildTimestamp(),
                    ],
                    SizedBox(height: 16.h),
                    widget.isActive
                        ? _buildActiveJobButtons()
                        : _buildOpenRequestButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isActive
              ? [_green, _green.withGreen(180)]
              : [_orange, _orange.withRed(230)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          // Location
          Icon(Icons.location_on, color: Colors.white, size: 18.w),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              widget.job['locationName'] ?? 'Location',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isUrgent && !widget.isActive)
                  _PulsingDot(color: Colors.white, size: 8.w),
                if (_isUrgent && !widget.isActive) SizedBox(width: 4.w),
                Text(
                  widget.isActive
                      ? "IN PROGRESS"
                      : _isUrgent
                      ? "URGENT"
                      : "OPEN",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Distance
          if (widget.job['distance'] != null) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.navigation, color: Colors.white, size: 12.w),
                  SizedBox(width: 4.w),
                  Text(
                    "${widget.job['distance']} km",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── PROBLEM SECTION ──────────────────────────────────────
  Widget _buildProblemSection() {
    final problem = widget.job['problem'] ?? 'Not specified';
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: _orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(_problemIcon(problem), color: _orange, size: 24.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        problem,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (_isVeryClose && !widget.isActive)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "VERY CLOSE",
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: _green,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.job['vehicleType'] ?? 'Vehicle not specified',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── DRIVER INFO ──────────────────────────────────────────
  Widget _buildDriverInfo() {
    return Row(
      children: [
        Icon(Icons.person, color: _orange, size: 20.w),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            widget.job['driverName'] ?? 'Driver',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        if (widget.job['driverPhone'] != null)
          GestureDetector(
            onTap: _callDriver,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, color: _primary, size: 16.w),
                  SizedBox(width: 6.w),
                  Text(
                    "Call",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ─── DESCRIPTION ──────────────────────────────────────────
  Widget _buildDescription() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notes_rounded, color: Colors.blue.shade600, size: 18.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              widget.job['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TIMESTAMP ────────────────────────────────────────────
  Widget _buildTimestamp() {
    return Row(
      children: [
        Icon(Icons.access_time, color: Colors.grey.shade500, size: 16.w),
        SizedBox(width: 6.w),
        Text(
          "Created $_timeAgo",
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ─── BUTTONS: ACTIVE JOB ─────────────────────────────────
  Widget _buildActiveJobButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _miniAction(Icons.phone, "Call", _primary, _callDriver),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _miniAction(
                Icons.chat_bubble,
                "Chat",
                _primary,
                _openChat,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _miniAction(
                Icons.navigation,
                "Navigate",
                Colors.blue,
                _navigateToDriver,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: widget.onCancel,
                icon: Icon(Icons.close, size: 18.w),
                label: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _red,
                  side: BorderSide(color: _red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_green, _green.withGreen(180)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _completeJob,
                  icon: Icon(Icons.check_circle, size: 20.w),
                  label: Text(
                    "Complete",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── BUTTONS: OPEN REQUEST ────────────────────────────────
  Widget _buildOpenRequestButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Reject = dismiss from view (no Firestore action needed)
            },
            icon: Icon(Icons.close, size: 18.w),
            label: Text(
              "Reject",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _red,
              side: BorderSide(color: _red, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_orange, const Color(0xFFF57C00)],
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: _orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onAccept?.call();
              },
              icon: Icon(Icons.check, size: 20.w),
              label: Text(
                "Accept Request",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18.w),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        elevation: 1,
      ),
    );
  }

  // ─── ACTIONS ──────────────────────────────────────────────
  void _callDriver() async {
    final phone = widget.job['driverPhone'];
    if (phone != null) {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar("Error", "Cannot make call");
      }
    } else {
      Get.snackbar("Error", "Phone number not available");
    }
  }

  void _navigateToDriver() async {
    final lat = widget.job['driverLat'];
    final lng = widget.job['driverLng'];
    if (lat != null && lng != null) {
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar("Error", "Cannot open maps");
      }
    } else {
      Get.snackbar("Error", "Location not available");
    }
  }

  void _completeJob() {
    Get.bottomSheet(
      const CompleteJobVerificationDialog(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _openChat() {
    final chatId = widget.job['id'] ?? '';
    if (chatId.isEmpty) {
      Get.snackbar('Error', 'Chat not available');
      return;
    }
    Get.delete<ChatController>(force: true);
    Get.put(
      ChatController(
        chatId: chatId,
        otherUserName: widget.job['driverName'] ?? 'Driver',
        otherUserPhoto: widget.job['driverPhoto'] ?? '',
        myRole: 'mechanic',
      ),
    );
    Get.to(
      () => ChatScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    );
  }
}

/// Pulsing dot indicator for urgent requests
class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({required this.color, required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.5 + _ctrl.value * 0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
