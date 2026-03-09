import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});


  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: Color(0xFF6C63FF)),
            tooltip: 'Mark all as read',
            onPressed: () {
              // Usually handled internally or with a batch update
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
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Use a generic query if specific indexing differs, here we order by createdAt descending
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Fallback if index is not ready
            return Center(
              child: Text(
                "Could not load notifications at this time (Index building).",
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80.w,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "No Notifications",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;
              final createdAt = data['createdAt'] as Timestamp?;
              final timeString = createdAt != null
                  ? DateFormat('MMM d, hh:mm a').format(createdAt.toDate())
                  : '';

              final type = data['type'] as String? ?? '';
              final title = data['title'] ?? 'Notification';
              final body = data['body'] ?? '';
              final payload = data['data'] as Map<String, dynamic>?;

              return Dismissible(
                key: Key(docs[index].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.w),
                  color: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  docs[index].reference.delete();
                },
                child: InkWell(
                  onTap: () {
                    if (!isRead) {
                      docs[index].reference.update({'isRead': true});
                    }
                    if (payload != null && payload['route'] != null) {
                      Get.toNamed(payload['route']);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isRead
                          ? Colors.white
                          : Colors.blue.shade50.withAlpha(128),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        if (!isRead)
                          BoxShadow(
                            color: Colors.blue.shade100,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: _getIconColor(type).withAlpha(38),
                          radius: 24.r,
                          child: Icon(
                            _getIcon(type),
                            color: _getIconColor(type),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: GoogleFonts.poppins(
                                        fontWeight: isRead
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 8.w,
                                      height: 8.h,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                body,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                timeString,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'new_request':
        return Icons.build_circle;
      case 'request_accepted':
        return Icons.check_circle;
      case 'mechanic_nearby':
        return Icons.location_on;
      case 'job_completed':
        return Icons.task_alt;
      case 'payment_received':
        return Icons.payments;
      case 'request_cancelled':
        return Icons.cancel;
      case 'chat_message':
        return Icons.chat;
      case 'rating_received':
        return Icons.star;
      case 'verification_approved':
        return Icons.verified;
      case 'verification_rejected':
        return Icons.warning;
      case 'promotional':
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'new_request':
        return Color(0xFFFF9800);
      case 'request_accepted':
        return Color(0xFF4CAF50);
      case 'mechanic_nearby':
        return Colors.blue;
      case 'job_completed':
        return Color(0xFF4CAF50);
      case 'payment_received':
        return Colors.green;
      case 'request_cancelled':
        return Colors.red;
      case 'chat_message':
        return Color(0xFF6C63FF);
      case 'rating_received':
        return Colors.amber;
      case 'verification_approved':
        return Colors.green;
      case 'verification_rejected':
        return Colors.red;
      case 'promotional':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
