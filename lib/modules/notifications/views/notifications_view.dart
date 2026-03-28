import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
            color: const Color(0xFF1A1D26),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1D26)),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.tick_circle,
              color: const Color(0xFF6C63FF),
              size: 22.w,
            ),
            tooltip: 'Mark all as read',
            onPressed: () => _markAllRead(uid),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            );
          }
          if (snapshot.hasError) {
            return _buildSetupMessage();
          }

          final docs =
              snapshot.data?.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['type'] != 'chat_message';
              }).toList() ??
              [];

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          // Group notifications by date
          final grouped = _groupByDate(docs);

          return ListView.builder(
            padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final group = grouped[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    child: Text(
                      group['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E92A4),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Notification cards in group
                  ...List.generate(
                    (group['docs'] as List).length,
                    (i) => _buildNotificationCard(
                      (group['docs'] as List<QueryDocumentSnapshot>)[i],
                      uid,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ─── Mark All Read ───
  void _markAllRead(String uid) {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get()
        .then((snapshot) {
          final batch = FirebaseFirestore.instance.batch();
          for (var doc in snapshot.docs) {
            batch.update(doc.reference, {'isRead': true});
          }
          batch.commit();
        });
  }

  // ─── Empty State ───
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFF),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Icon(
              Iconsax.notification,
              size: 36.w,
              color: const Color(0xFF6C63FF),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "All caught up!",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D26),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "You have no new notifications",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: const Color(0xFF8E92A4),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Index Building State ───
  Widget _buildSetupMessage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.info_circle,
              size: 48.w,
              color: const Color(0xFF6C63FF),
            ),
            SizedBox(height: 16.h),
            Text(
              "Setting things up...",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1D26),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Notifications will be available shortly.\nPlease try again in a few minutes.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: const Color(0xFF8E92A4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Notification Card ───
  Widget _buildNotificationCard(QueryDocumentSnapshot doc, String uid) {
    final data = doc.data() as Map<String, dynamic>;
    final isRead = data['isRead'] ?? false;
    final createdAt = data['createdAt'] as Timestamp?;
    final timeString = createdAt != null ? _formatTime(createdAt.toDate()) : '';

    final type = data['type'] as String? ?? '';
    final title = data['title'] ?? 'Notification';
    final body = data['body'] ?? '';
    final payload = data['data'] as Map<String, dynamic>?;

    final config = _getNotificationConfig(type);

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(Iconsax.trash, color: Colors.white, size: 22.w),
      ),
      onDismissed: (_) => doc.reference.delete(),
      child: GestureDetector(
        onTap: () {
          if (!isRead) doc.reference.update({'isRead': true});
          if (payload != null && payload['route'] != null) {
            Get.toNamed(payload['route']);
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFF0EEFF),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isRead ? const Color(0xFFEEEFF3) : const Color(0xFFD4D0FF),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: config.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(config.icon, color: config.color, size: 22.w),
              ),
              SizedBox(width: 12.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              fontSize: 13.5.sp,
                              color: const Color(0xFF1A1D26),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          timeString,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: const Color(0xFFA0A4B2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!isRead) ...[
                          SizedBox(width: 6.w),
                          Container(
                            width: 7.w,
                            height: 7.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6C63FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      body,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        color: const Color(0xFF5A5E72),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Date Grouping ───
  List<Map<String, dynamic>> _groupByDate(List<QueryDocumentSnapshot> docs) {
    final Map<String, List<QueryDocumentSnapshot>> groups = {};
    final now = DateTime.now();

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'] as Timestamp?;
      if (createdAt == null) continue;

      final date = createdAt.toDate();
      String label;

      if (_isSameDay(date, now)) {
        label = 'TODAY';
      } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
        label = 'YESTERDAY';
      } else if (now.difference(date).inDays < 7) {
        label = DateFormat('EEEE').format(date).toUpperCase();
      } else {
        label = DateFormat('MMM d, yyyy').format(date).toUpperCase();
      }

      groups.putIfAbsent(label, () => []);
      groups[label]!.add(doc);
    }

    return groups.entries
        .map((e) => {'label': e.key, 'docs': e.value})
        .toList();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(date);
  }

  // ─── Config per notification type ───
  _NotifConfig _getNotificationConfig(String type) {
    switch (type) {
      case 'new_request':
        return _NotifConfig(Iconsax.warning_2, const Color(0xFFFF6B35));
      case 'request_accepted':
        return _NotifConfig(Iconsax.tick_circle, const Color(0xFF22C55E));
      case 'mechanic_nearby':
        return _NotifConfig(Iconsax.location, const Color(0xFF3B82F6));
      case 'job_completed':
        return _NotifConfig(Iconsax.task_square, const Color(0xFF22C55E));
      case 'payment_received':
        return _NotifConfig(Iconsax.wallet_2, const Color(0xFF10B981));
      case 'request_cancelled':
        return _NotifConfig(Iconsax.close_circle, const Color(0xFFEF4444));
      case 'chat_message':
        return _NotifConfig(Iconsax.message, const Color(0xFF6C63FF));
      case 'rating_received':
        return _NotifConfig(Iconsax.star1, const Color(0xFFF59E0B));
      case 'verification_approved':
        return _NotifConfig(Iconsax.verify, const Color(0xFF22C55E));
      case 'verification_rejected':
        return _NotifConfig(Iconsax.info_circle, const Color(0xFFEF4444));
      default:
        return _NotifConfig(Iconsax.notification, const Color(0xFF8E92A4));
    }
  }
}

class _NotifConfig {
  final IconData icon;
  final Color color;
  const _NotifConfig(this.icon, this.color);
}
