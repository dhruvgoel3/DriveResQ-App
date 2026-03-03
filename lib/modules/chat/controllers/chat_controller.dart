import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final String chatId;
  final String otherUserName;
  final String otherUserPhoto;
  final String myRole; // 'driver' or 'mechanic'

  ChatController({
    required this.chatId,
    required this.otherUserName,
    required this.otherUserPhoto,
    required this.myRole,
  });

  final _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();

  final textController = TextEditingController();
  final scrollController = ScrollController();

  var messages = <MessageModel>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var showQuickReplies = false.obs;

  StreamSubscription? _msgSub;

  String get _uid => _auth.currentUser?.uid ?? '';

  // Quick reply options
  List<String> get quickReplies {
    if (myRole == 'mechanic') {
      return [
        "I'm on my way! 🚗",
        "Arriving in 10 minutes",
        "Please share exact location",
        "What's the problem exactly?",
        "I need to check the vehicle first",
        "Work started ⚙️",
        "Almost done!",
      ];
    } else {
      return [
        "How long will you take?",
        "What will be the cost?",
        "Please hurry, it's urgent! 🚨",
        "Do you need any information?",
        "I'm at the exact pin location",
        "Thank you!",
      ];
    }
  }

  @override
  void onInit() {
    super.onInit();
    _listenMessages();
    ChatService.markAsRead(chatId, myRole);
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _listenMessages() {
    _msgSub = ChatService.messagesStream(chatId).listen((list) {
      messages.value = list;
      ChatService.markAsRead(chatId, myRole);
    });
  }

  // ─── Send text message ───
  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    textController.clear();
    isSending.value = true;

    try {
      await ChatService.sendMessage(
        chatId: chatId,
        content: text,
        senderRole: myRole,
      );
    } catch (e) {
      debugPrint('❌ Send error: $e');
      Get.snackbar('Error', 'Failed to send message');
    }

    isSending.value = false;
  }

  // ─── Send quick reply ───
  void sendQuickReply(String text) {
    textController.text = text;
    sendMessage();
    showQuickReplies.value = false;
  }

  // ─── Pick and send image ───
  Future<void> pickAndSendImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 60);
    if (picked == null) return;

    isSending.value = true;
    try {
      await ChatService.sendImageFromPath(
        chatId: chatId,
        imagePath: picked.path,
        senderRole: myRole,
      );
    } catch (e) {
      debugPrint('❌ Image send error: $e');
      Get.snackbar('Error', 'Failed to send image');
    }
    isSending.value = false;
  }

  // ─── Send price estimate (mechanic only) ───
  Future<void> sendEstimate({
    required String service,
    required double cost,
    required String time,
    String? notes,
    List<String>? parts,
  }) async {
    isSending.value = true;
    try {
      await ChatService.sendPriceQuote(
        chatId: chatId,
        service: service,
        estimatedCost: cost,
        estimatedTime: time,
        notes: notes,
        parts: parts,
      );
    } catch (e) {
      debugPrint('❌ Estimate error: $e');
      Get.snackbar('Error', 'Failed to send estimate');
    }
    isSending.value = false;
  }

  // ─── Respond to price quote (driver only) ───
  Future<void> respondToQuote(
    String messageId,
    String response, {
    double? counterOffer,
    String? reason,
  }) async {
    try {
      await ChatService.respondToPriceQuote(
        chatId: chatId,
        messageId: messageId,
        response: response,
        counterOffer: counterOffer,
        reason: reason,
      );
    } catch (e) {
      debugPrint('❌ Quote response error: $e');
    }
  }

  bool isMe(MessageModel msg) => msg.senderId == _uid;
}
