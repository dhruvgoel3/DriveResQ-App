import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import 'chat_screen.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class ChatListView extends StatelessWidget {
  static const _accent = Color(0xFF6C63FF);

  const ChatListView({super.key});

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: _uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.w,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Error loading chats',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.red.shade400,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerLoader(itemCount: 5, cardType: ShimmerCardType.chat);
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.chat_bubble_outline,
              iconColor: Color(0xFF6C63FF),
              title: 'No Messages Yet',
              message:
                  'Chats will appear here when a mechanic accepts your request.',
              tips: [
                'Chat with your mechanic in real time',
                'Share photos and negotiate prices',
                'All your conversations in one place',
              ],
            );
          }

          // Sort client-side by lastMessageTime (avoids Firestore composite index)
          final chats = snapshot.data!.docs.toList();
          chats.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['lastMessageTime'];
            final bTime = bData['lastMessageTime'];

            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;

            if (aTime is Timestamp && bTime is Timestamp) {
              return bTime.compareTo(aTime);
            }
            return 0; // Fallback for invalid formats
          });

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: chats.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, indent: 76, color: Colors.grey.shade200),
            itemBuilder: (_, i) {
              final chat = chats[i].data() as Map<String, dynamic>;
              final chatId = chats[i].id;
              return _chatTile(chat, chatId);
            },
          );
        },
      ),
    );
  }

  Widget _chatTile(Map<String, dynamic> chat, String chatId) {
    final isDriver = _uid == chat['driverId'];
    final otherId = isDriver ? chat['mechanicId'] : chat['driverId'];
    var otherName = isDriver
        ? (chat['mechanicName'] ?? 'Mechanic')
        : (chat['driverName'] ?? 'Driver');
    var otherPhoto = isDriver
        ? (chat['mechanicPhoto'] ?? '')
        : (chat['driverPhoto'] ?? '');
    
    final myRole = isDriver ? 'driver' : 'mechanic';
    final unreadCount = isDriver
        ? (chat['driverUnreadCount'] ?? 0)
        : (chat['mechanicUnreadCount'] ?? 0);

    final lastMsg = chat['lastMessage'] ?? '';
    final lastTime = chat['lastMessageTime'];
    final status = chat['status'] ?? 'active';

    // If the name is generic, try fetching the real name from the users collection
    final needsRefresh = otherName == 'Driver' || otherName == 'Mechanic' || otherName.isEmpty;
    
    return FutureBuilder<DocumentSnapshot?>(
      future: needsRefresh && otherId != null
          ? FirebaseFirestore.instance.collection('users').doc(otherId).get()
          : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          otherName = userData['fullName'] ?? userData['name'] ?? otherName;
          otherPhoto = userData['profilePhotoUrl'] ?? userData['photoUrl'] ?? otherPhoto;
          
          // Optionally update the chat document in the background so we don't need to fetch again
          if (otherName != 'Driver' && otherName != 'Mechanic') {
            final updateFields = isDriver
                ? {'mechanicName': otherName, 'mechanicPhoto': otherPhoto}
                : {'driverName': otherName, 'driverPhoto': otherPhoto};
            FirebaseFirestore.instance.collection('chats').doc(chatId).update(updateFields).catchError((_) {});
          }
        }

        return Material(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              Get.delete<ChatController>(force: true);
              Get.put(
                ChatController(
                  chatId: chatId,
                  otherUserName: otherName,
                  otherUserPhoto: otherPhoto,
                  myRole: myRole,
                ),
              );
              Get.to(
                () => ChatScreen(),
                transition: Transition.rightToLeft,
                duration: Duration(milliseconds: 250),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 26.r,
                        backgroundImage: otherPhoto.isNotEmpty
                            ? CachedNetworkImageProvider(otherPhoto)
                            : null,
                        backgroundColor: _accent.withOpacity(0.1),
                        child: otherPhoto.isEmpty
                            ? Icon(
                                isDriver ? Icons.build : Icons.directions_car,
                                color: _accent,
                                size: 22.w,
                              )
                            : null,
                      ),
                      if (status == 'active')
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 14.w),

                  // Name + last message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                otherName,
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  color: Colors.black87,
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              _formatTime(lastTime),
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: unreadCount > 0
                                    ? _accent
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lastMsg,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: unreadCount > 0
                                      ? Colors.black87
                                      : Colors.grey.shade500,
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _accent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
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
  }

  String _formatTime(dynamic ts) {
    if (ts == null) return '';
    DateTime dt;
    try {
      dt = (ts as Timestamp).toDate();
    } catch (_) {
      return '';
    }
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays > 0) {
      if (diff.inDays == 1) return 'Yesterday';
      return '${dt.day}/${dt.month}';
    }

    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}
