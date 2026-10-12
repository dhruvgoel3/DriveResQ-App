import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../driver/controllers/driver_controller.dart';
import '../models/chat_message.dart';
import '../services/resq_assistant_service.dart';

class ResQAssistantController extends GetxController {
  final ResQAssistantService _service;

  ResQAssistantController({ResQAssistantService? service})
      : _service = service ?? ResQAssistantService();

  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isTyping = false.obs;
  final errorMessage = Rxn<String>();

  final textController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  final List<String> suggestedPrompts = const [
    "Gaadi start nahi ho rahi 🚗",
    "Tyre puncture ho gaya 🛞",
    "Engine garam ho raha hai 🌡️",
    "Highway pe gaadi ruk gayi 🛣️",
    "Mechanic aane tak kya karein? ⏳",
    "Engine se dhuan aa raha hai 🚨",
  ];

  final activeRequestContext = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _initializeContext();
    _addInitialGreeting();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _service.dispose();
    super.onClose();
  }

  /// Inspects authenticated roadside context from DriverController if available
  void _initializeContext() {
    if (Get.isRegistered<DriverController>()) {
      final driverController = Get.find<DriverController>();
      if (driverController.hasActiveRequest.value &&
          driverController.requestData.value != null) {
        final req = driverController.requestData.value!;
        activeRequestContext.value = {
          'vehicleType': req['vehicleType'] ?? 'Unknown',
          'breakdownCategory': req['problemDescription'] ?? req['problem'] ?? 'General breakdown',
          'requestStatus': req['status'] ?? 'active',
        };
      }
    }
  }

  void _addInitialGreeting() {
    messages.add(
      ChatMessage(
        id: 'msg_welcome_${DateTime.now().millisecondsSinceEpoch}',
        text: "Namaste! Main hoon **ResQ Assistant**, aapka AI Roadside Safety Companion. 🚗\n\n"
            "⚠️ **Safety First / Suraksha**: Agar aapki gaadi sadak par ruki hai, toh sabse pehle **Hazard flashers** on karein aur traffic se door safe jagah par chale jayein.\n\n"
            "Aap mujhse **English ya Hinglish** me baat kar sakte hain (jaise: *\"Gaadi start nahi ho rahi\"*, *\"Engine garam ho gaya\"*, *\"Tyre badalna hai\"*).",
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      ),
    );
  }

  /// Submits user message
  Future<void> sendMessage([String? customText]) async {
    final rawText = customText ?? textController.text;
    final text = rawText.trim();

    if (text.isEmpty || isLoading.value) return;

    textController.clear();
    errorMessage.value = null;

    final userMessageId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final userMessage = ChatMessage(
      id: userMessageId,
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    messages.add(userMessage);
    scrollToBottom();

    isLoading.value = true;
    isTyping.value = true;

    try {
      // Gather relevant history excluding error messages
      final history = messages
          .where((m) => m.status == MessageStatus.sent && m.id != userMessageId)
          .toList();

      final reply = await _service.askAssistant(
        message: text,
        history: history,
        context: activeRequestContext.value,
      );

      final assistantMessage = ChatMessage(
        id: 'ast_${DateTime.now().millisecondsSinceEpoch}',
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      messages.add(assistantMessage);
    } catch (e) {
      final errText = e is ResQAssistantException
          ? e.message
          : 'ResQ Assistant is temporarily unavailable. Please try again or contact your mechanic directly.';

      errorMessage.value = errText;

      // Append assistant error response with retry option
      final errorResponse = ChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        text: errText,
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
        errorMessage: errText,
      );

      messages.add(errorResponse);
    } finally {
      isLoading.value = false;
      isTyping.value = false;
      scrollToBottom();
    }
  }

  /// Triggered when tapping a suggested prompt chip
  void sendSuggestedPrompt(String prompt) {
    if (isLoading.value) return;
    sendMessage(prompt);
  }

  /// Retries the last user message
  Future<void> retryLastMessage() async {
    ChatMessage? lastUserMsg;
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].isUser) {
        lastUserMsg = messages[i];
        break;
      }
    }
    if (lastUserMsg != null) {
      // Remove trailing error messages if any
      while (messages.isNotEmpty && messages.last.status == MessageStatus.error) {
        messages.removeLast();
      }
      await sendMessage(lastUserMsg.text);
    }
  }

  /// Clears the chat conversation and restarts with the safety welcome message
  void clearConversation() {
    messages.clear();
    errorMessage.value = null;
    _addInitialGreeting();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }
}
