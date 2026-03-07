import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart';
import '../widgets/price_quote_card.dart';
import '../widgets/quick_replies.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static const _accent = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(c),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Obx(() {
              if (c.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No messages yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Say hello! 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: c.scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: c.messages.length,
                itemBuilder: (_, i) {
                  final msg = c.messages[i];
                  final isMe = c.isMe(msg);

                  // Price quote
                  if (msg.type == 'price_quote') {
                    return PriceQuoteCard(
                      message: msg,
                      isMe: isMe,
                      controller: c,
                    );
                  }

                  return MessageBubble(message: msg, isMe: isMe);
                },
              );
            }),
          ),

          // Quick replies
          Obx(
            () => c.showQuickReplies.value
                ? QuickRepliesBar(
                    replies: c.quickReplies,
                    onTap: c.sendQuickReply,
                  )
                : const SizedBox.shrink(),
          ),

          // Input bar
          _buildInputBar(c),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatController c) {
    return AppBar(
      backgroundColor: _accent,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leadingWidth: 36,
      leading: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => Get.back(),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: c.otherUserPhoto.isNotEmpty
                ? NetworkImage(c.otherUserPhoto)
                : null,
            backgroundColor: Colors.white24,
            child: c.otherUserPhoto.isEmpty
                ? const Icon(Icons.person, color: Colors.white70, size: 18)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.otherUserName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  c.myRole == 'driver' ? 'Mechanic' : 'Driver',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Estimate button (mechanic only)
        if (c.myRole == 'mechanic')
          IconButton(
            icon: const Icon(Icons.receipt_long, size: 22),
            tooltip: 'Send Estimate',
            onPressed: () => _showEstimateDialog(c),
          ),
        IconButton(icon: const Icon(Icons.phone, size: 22), onPressed: () {}),
      ],
    );
  }

  Widget _buildInputBar(ChatController c) {
    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(Get.context!).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attach
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.grey.shade500,
              size: 24,
            ),
            onPressed: () => _showAttachMenu(c),
          ),

          // Quick replies toggle
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.flash_on,
                color: c.showQuickReplies.value
                    ? _accent
                    : Colors.grey.shade500,
                size: 24,
              ),
              onPressed: () =>
                  c.showQuickReplies.value = !c.showQuickReplies.value,
            ),
          ),

          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: c.textController,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Send
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: c.isSending.value ? Colors.grey.shade300 : _accent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: c.isSending.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: c.isSending.value ? null : c.sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachMenu(ChatController c) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _attachOption(Icons.camera_alt, 'Camera', Colors.red, () {
                  Get.back();
                  c.pickAndSendImage(source: ImageSource.camera);
                }),
                _attachOption(Icons.photo, 'Gallery', Colors.purple, () {
                  Get.back();
                  c.pickAndSendImage(source: ImageSource.gallery);
                }),
                _attachOption(Icons.location_on, 'Location', Colors.green, () {
                  Get.back();
                  c.sendQuickReply('📍 Sharing my current location');
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _attachOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showEstimateDialog(ChatController c) {
    final serviceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Send Service Estimate',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: serviceCtrl,
                decoration: InputDecoration(
                  labelText: 'Service Description *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: costCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cost (₹) *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: timeCtrl,
                      decoration: InputDecoration(
                        labelText: 'Est. Time *',
                        hintText: 'e.g. 1 hour',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final cost = double.tryParse(costCtrl.text);
                    if (serviceCtrl.text.trim().isEmpty ||
                        cost == null ||
                        timeCtrl.text.trim().isEmpty) {
                      Get.snackbar('Required', 'Fill service, cost and time');
                      return;
                    }
                    Get.back();
                    c.sendEstimate(
                      service: serviceCtrl.text.trim(),
                      cost: cost,
                      time: timeCtrl.text.trim(),
                      notes: notesCtrl.text.trim().isNotEmpty
                          ? notesCtrl.text.trim()
                          : null,
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: Text(
                    'Send Estimate',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
