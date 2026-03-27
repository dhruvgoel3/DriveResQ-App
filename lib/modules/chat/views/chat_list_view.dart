import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../controllers/chat_controller.dart';
import 'chat_screen.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Messages',
          style: AppTextStyles.h1.copyWith(fontSize: 22.sp),
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
                    Iconsax.close_circle,
                    size: 64.w,
                    color: AppColors.error.withOpacity(0.7),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Error loading chats',
                    style: AppTextStyles.body1.copyWith(color: AppColors.error),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
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
              icon: Iconsax.message,
              iconColor: AppColors.primary,
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
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 76.w,
              color: AppColors.border.withOpacity(0.5),
            ),
            itemBuilder: (_, i) {
              final chat = chats[i].data() as Map<String, dynamic>;
              final chatId = chats[i].id;
              return _ChatTile(chat: chat, chatId: chatId, uid: _uid);
            },
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final String chatId;
  final String uid;

  const _ChatTile({
    required this.chat,
    required this.chatId,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final isDriver = uid == chat['driverId'];
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

    final needsRefresh =
        otherName == 'Driver' || otherName == 'Mechanic' || otherName.isEmpty;

    return FutureBuilder<DocumentSnapshot?>(
      future: needsRefresh && otherId != null
          ? FirebaseFirestore.instance.collection('users').doc(otherId).get()
          : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          otherName = userData['fullName'] ?? userData['name'] ?? otherName;
          otherPhoto =
              userData['profilePhotoUrl'] ?? userData['photoUrl'] ?? otherPhoto;

          if (otherName != 'Driver' && otherName != 'Mechanic') {
            final updateFields = isDriver
                ? {'mechanicName': otherName, 'mechanicPhoto': otherPhoto}
                : {'driverName': otherName, 'driverPhoto': otherPhoto};
            FirebaseFirestore.instance
                .collection('chats')
                .doc(chatId)
                .update(updateFields)
                .catchError((_) {});
          }
        }

        return Material(
          color: AppColors.surface,
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
                () => const ChatScreen(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 250),
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
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: otherPhoto.isEmpty
                            ? Icon(
                                Iconsax.user,
                                color: AppColors.primary,
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
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2.w,
                              ),
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
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              _formatTime(lastTime),
                              style: AppTextStyles.caption.copyWith(
                                color: unreadCount > 0
                                    ? AppColors.primary
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lastMsg,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body2.copyWith(
                                  color: unreadCount > 0
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 2.h,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.surface,
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
