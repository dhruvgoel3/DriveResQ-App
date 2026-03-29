import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../../../shared/services/error_handler.dart';
import '../../../utils/helpers/app_snackbar.dart';

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
  var hasText = false.obs;

  // ─── Voice recording state ───
  final _recorder = AudioRecorder();
  final audioPlayer = AudioPlayer();
  var isRecording = false.obs;
  var recordingDuration = 0.obs;
  var isPlaying = false.obs;
  var currentlyPlayingId = ''.obs;
  var playbackProgress = 0.0.obs;
  Timer? _recordingTimer;
  String? _recordingPath;

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
    _setupAudioPlayerListeners();
    textController.addListener(() {
      hasText.value = textController.text.trim().isNotEmpty;
    });
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    textController.dispose();
    scrollController.dispose();
    _recordingTimer?.cancel();
    _recorder.dispose();
    audioPlayer.dispose();
    super.onClose();
  }

  void _setupAudioPlayerListeners() {
    audioPlayer.onPlayerComplete.listen((_) {
      isPlaying.value = false;
      currentlyPlayingId.value = '';
      playbackProgress.value = 0.0;
    });

    audioPlayer.onPositionChanged.listen((pos) {
      audioPlayer.getDuration().then((dur) {
        if (dur != null && dur.inMilliseconds > 0) {
          playbackProgress.value = pos.inMilliseconds / dur.inMilliseconds;
        }
      });
    });
  }

  void _listenMessages() {
    _msgSub = ChatService.getMessages(chatId).listen((list) {
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
      debugPrint(' Send error: $e');
      ErrorHandler.handle(e);
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
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked == null) return;

      isSending.value = true;
      try {
        await ChatService.sendImage(
          chatId: chatId,
          localPath: picked.path,
          senderRole: myRole,
        );
      } catch (e) {
        debugPrint(' Image send error: $e');
        ErrorHandler.handle(e);
      } finally {
        isSending.value = false;
      }
    } catch (e) {
      debugPrint(' Image picker error: $e');
      ErrorHandler.handle(e);
      isSending.value = false;
    }
  }

  // ─── Voice recording ───
  Future<void> startRecording() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        AppSnackbar.warning(
          'Microphone permission is needed to send voice messages',
          title: 'Permission Required',
        );
        return;
      }

      // Get temp directory for recording
      final dir = await getTemporaryDirectory();
      _recordingPath =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Start recording
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath!,
        );

        isRecording.value = true;
        recordingDuration.value = 0;

        // Start a timer to track duration
        _recordingTimer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => recordingDuration.value++,
        );
      }
    } catch (e) {
      debugPrint(' Recording error: $e');
      AppSnackbar.error('Could not start recording');
    }
  }

  Future<void> stopAndSendRecording() async {
    if (!isRecording.value) return;

    _recordingTimer?.cancel();
    isRecording.value = false;

    try {
      final path = await _recorder.stop();
      if (path == null || recordingDuration.value < 1) {
        // Too short, discard
        AppSnackbar.info(
          'Hold longer to record a voice message',
          title: 'Too Short',
        );
        return;
      }

      isSending.value = true;
      await ChatService.sendVoiceMessage(
        chatId: chatId,
        audioPath: path,
        senderRole: myRole,
        durationSeconds: recordingDuration.value,
      );
    } catch (e) {
      debugPrint(' Voice send error: $e');
      ErrorHandler.handle(e);
    }

    isSending.value = false;
    recordingDuration.value = 0;
  }

  Future<void> cancelRecording() async {
    if (!isRecording.value) return;

    _recordingTimer?.cancel();
    isRecording.value = false;
    recordingDuration.value = 0;

    try {
      await _recorder.stop();
    } catch (_) {}
  }

  // ─── Voice playback ───
  Future<void> playVoice(String messageId, String url) async {
    try {
      if (isPlaying.value && currentlyPlayingId.value == messageId) {
        // Pause if same message
        await audioPlayer.pause();
        isPlaying.value = false;
        return;
      }

      // Stop any current playback
      await audioPlayer.stop();
      playbackProgress.value = 0.0;

      // Play the new one
      currentlyPlayingId.value = messageId;
      isPlaying.value = true;
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint(' Playback error: $e');
      isPlaying.value = false;
      currentlyPlayingId.value = '';
    }
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
      debugPrint(' Estimate error: $e');
      AppSnackbar.error('Failed to send estimate');
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
      await ChatService.respondToQuote(
        chatId: chatId,
        messageId: messageId,
        responseStatus: response,
        counterOffer: counterOffer,
        reason: reason,
      );
    } catch (e) {
      debugPrint(' Quote response error: $e');
    }
  }

  bool isMe(MessageModel msg) => msg.senderId == _uid;

  String formatRecordingDuration() {
    final mins = recordingDuration.value ~/ 60;
    final secs = recordingDuration.value % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
