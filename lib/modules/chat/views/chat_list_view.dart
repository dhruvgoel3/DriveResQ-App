import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import 'chat_screen.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  static const _accent = Color(0xFF6C63FF);

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            fontSize: 22,
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
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error loading chats',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Chats will appear when a request is accepted',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort client-side by lastMessageTime (avoids Firestore composite index)
          final chats = snapshot.data!.docs.toList();
          chats.sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['lastMessageTime'];
            final bTime = (b.data() as Map<String, dynamic>)['lastMessageTime'];
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return (bTime as Timestamp).compareTo(aTime as Timestamp);
          });

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
    final otherName = isDriver
        ? (chat['mechanicName'] ?? 'Mechanic')
        : (chat['driverName'] ?? 'Driver');
    final otherPhoto = isDriver
        ? (chat['mechanicPhoto'] ?? '')
        : (chat['driverPhoto'] ?? '');
    final myRole = isDriver ? 'driver' : 'mechanic';
    final unreadCount = isDriver
        ? (chat['driverUnreadCount'] ?? 0)
        : (chat['mechanicUnreadCount'] ?? 0);

    final lastMsg = chat['lastMessage'] ?? '';
    final lastTime = chat['lastMessageTime'];
    final status = chat['status'] ?? 'active';

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
            () => const ChatScreen(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 250),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: otherPhoto.isNotEmpty
                        ? NetworkImage(otherPhoto)
                        : null,
                    backgroundColor: _accent.withOpacity(0.1),
                    child: otherPhoto.isEmpty
                        ? Icon(
                            isDriver ? Icons.build : Icons.directions_car,
                            color: _accent,
                            size: 22,
                          )
                        : null,
                  ),
                  if (status == 'active')
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

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
                              fontSize: 15,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(lastTime),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: unreadCount > 0
                                ? _accent
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMsg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: _accent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
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
