import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../notifications/services/notification_sender.dart';
import '../models/message_model.dart';

/// A comprehensive service for managing real-time chat between Drivers and Mechanics.
///
/// Handles:
/// - Chat room initialization.
/// - Text, image, voice, and system message dispatch.
/// - Automated push notifications for new messages.
/// - Quote negotiation and agreement tracking.
class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _currentUid => _auth.currentUser?.uid ?? '';

  // ---------------------------------------------------------------------------
  // 💬 CHAT INITIALIZATION
  // ---------------------------------------------------------------------------

  /// Creates a persistent chat room for a specific request.
  ///
  /// Automatically resolves participant names and profile photos from Firestore
  /// if they are missing or hold generic placeholders.
  static Future<void> createChat({
    required String requestId,
    required String driverId,
    required String mechanicId,
    String? driverName,
    String? mechanicName,
    String? driverPhoto,
    String? mechanicPhoto,
  }) async {
    final chatRef = _firestore.collection('chats').doc(requestId);

    String resolvedDriverName = driverName ?? 'Driver';
    String resolvedMechanicName = mechanicName ?? 'Mechanic';
    String resolvedDriverPhoto = driverPhoto ?? '';
    String resolvedMechanicPhoto = mechanicPhoto ?? '';

    // Enforce name resolution from DB if defaults are provided
    try {
      if (resolvedDriverName == 'Driver' || resolvedDriverName.isEmpty) {
        final doc = await _firestore.collection('users').doc(driverId).get();
        if (doc.exists) {
          final data = doc.data()!;
          resolvedDriverName = data['fullName'] ?? data['name'] ?? 'Driver';
          resolvedDriverPhoto =
              data['profilePhotoUrl'] ?? data['photoUrl'] ?? '';
        }
      }

      if (resolvedMechanicName == 'Mechanic' || resolvedMechanicName.isEmpty) {
        final doc = await _firestore.collection('users').doc(mechanicId).get();
        if (doc.exists) {
          final data = doc.data()!;
          resolvedMechanicName = data['fullName'] ?? data['name'] ?? 'Mechanic';
          resolvedMechanicPhoto =
              data['profilePhotoUrl'] ?? data['photoUrl'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('ChatService.createChat: failed to resolve names: $e');
    }

    await chatRef.set({
      'participants': FieldValue.arrayUnion([driverId, mechanicId]),
      'driverId': driverId,
      'mechanicId': mechanicId,
      'driverName': resolvedDriverName,
      'mechanicName': resolvedMechanicName,
      'driverPhoto': resolvedDriverPhoto,
      'mechanicPhoto': resolvedMechanicPhoto,
      'lastMessage': 'Conversations started...',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageBy': 'system',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await sendSystemMessage(
      requestId,
      '🤝 Welcome! Contact details and location are shared. Discuss service details here.',
    );
  }

  // ---------------------------------------------------------------------------
  // ✉️ MESSAGE DISPATCH
  // ---------------------------------------------------------------------------

  /// Sends a plain text message to the chat.
  static Future<void> sendMessage({
    required String chatId,
    required String content,
    required String senderRole,
  }) async {
    final senderName = await _resolveSenderName(chatId, senderRole);

    final messageData = {
      'senderId': _currentUid,
      'senderName': senderName,
      'senderRole': senderRole,
      'type': 'text',
      'content': content.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'delivered': true,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    await _updateChatPulse(chatId, content, senderRole);

    // Trigger external notification
    _dispatchNotification(chatId, senderRole, content, senderName);
  }

  /// Sends an automated system notice to the chat participants.
  static Future<void> sendSystemMessage(String chatId, String content) async {
    final messageData = {
      'senderId': 'system',
      'senderName': 'System',
      'senderRole': 'system',
      'type': 'system',
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'delivered': true,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageBy': 'system',
    }, SetOptions(merge: true));
  }

  /// Uploads and sends an image file.
  static Future<void> sendImage({
    required String chatId,
    required String localPath,
    required String senderRole,
    String caption = '',
  }) async {
    final senderName = await _resolveSenderName(chatId, senderRole);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = _storage.ref('chats/$chatId/images/$fileName');

    // 1. Upload to Storage
    final file = File(localPath);
    if (!await file.exists()) throw Exception('Image source not found.');

    final uploadTask = storageRef.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // 2. Add to Firestore
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': _currentUid,
          'senderName': senderName,
          'senderRole': senderRole,
          'type': 'image',
          'content': caption.trim(),
          'imageUrl': downloadUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'delivered': true,
        });

    await _updateChatPulse(chatId, '📷 Photo', senderRole);
    _dispatchNotification(chatId, senderRole, '📷 Photo', senderName);
  }

  /// Uploads and sends a voice recording.
  static Future<void> sendVoiceMessage({
    required String chatId,
    required String audioPath,
    required String senderRole,
    required int durationSeconds,
  }) async {
    final senderName = await _resolveSenderName(chatId, senderRole);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final storageRef = _storage.ref('chats/$chatId/voice/$fileName');

    final file = File(audioPath);
    if (!await file.exists()) throw Exception('Recording source not found.');

    final uploadTask = storageRef.putFile(
      file,
      SettableMetadata(contentType: 'audio/m4a'),
    );
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': _currentUid,
          'senderName': senderName,
          'senderRole': senderRole,
          'type': 'voice',
          'content': '',
          'audioUrl': downloadUrl,
          'audioDuration': durationSeconds,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'delivered': true,
        });

    await _updateChatPulse(chatId, '🎤 Voice Message', senderRole);
    _dispatchNotification(chatId, senderRole, '🎤 Voice Message', senderName);
  }

  // ---------------------------------------------------------------------------
  // 💰 PRICE NEGOTIATION
  // ---------------------------------------------------------------------------

  /// Dispatches a structured price estimate to the driver.
  static Future<void> sendPriceQuote({
    required String chatId,
    required String service,
    required double estimatedCost,
    required String estimatedTime,
    String? notes,
    List<String>? parts,
  }) async {
    final senderName = await _resolveSenderName(chatId, 'mechanic');
    final formattedPrice = '₹${estimatedCost.toStringAsFixed(0)}';

    final priceData = {
      'service': service,
      'estimatedCost': estimatedCost,
      'estimatedTime': estimatedTime,
      'notes': notes ?? '',
      'parts': parts ?? [],
      'status': 'pending',
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': _currentUid,
          'senderName': senderName,
          'senderRole': 'mechanic',
          'type': 'price_quote',
          'content': 'Service Estimate: $formattedPrice',
          'priceData': priceData,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'delivered': true,
        });

    await _updateChatPulse(chatId, '💰 Estimate: $formattedPrice', 'mechanic');
    _dispatchNotification(
      chatId,
      'mechanic',
      '💰 Estimate: $formattedPrice',
      senderName,
    );
  }

  /// Updates the status of a specific price quote based on driver interaction.
  static Future<void> respondToQuote({
    required String chatId,
    required String messageId,
    required String responseStatus, // 'accepted', 'rejected', 'negotiated'
    double? counterOffer,
    String? reason,
  }) async {
    final msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final snapshot = await msgRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final priceData = Map<String, dynamic>.from(data['priceData'] ?? {});

    priceData['status'] = responseStatus;
    if (counterOffer != null) priceData['counterOffer'] = counterOffer;
    if (reason != null) priceData['reason'] = reason;

    await msgRef.update({'priceData': priceData});

    // Send visual confirmation in chat
    if (responseStatus == 'accepted') {
      final cost = priceData['estimatedCost'] ?? 0;
      await _firestore.collection('chats').doc(chatId).update({
        'priceAgreed': cost,
      });
      await sendSystemMessage(
        chatId,
        '✅ Price agreed: ₹${(cost as num).toStringAsFixed(0)}',
      );
    } else if (responseStatus == 'rejected') {
      await sendSystemMessage(
        chatId,
        '❌ Estimate declined${reason != null ? ': $reason' : ''}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 🛰️ DATA STREAMS & READ LOGIC
  // ---------------------------------------------------------------------------

  /// Stream of messages for a specific chat, ordered by recent first.
  static Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MessageModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  /// Stream of all active chats for the current user.
  static Stream<QuerySnapshot> getActiveChats() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUid)
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  /// Marks all unread messages as read for the given [chatId].
  static Future<void> markAsRead(String chatId, String role) async {
    final unreadField = (role == 'driver')
        ? 'driverUnreadCount'
        : 'mechanicUnreadCount';
    await _firestore.collection('chats').doc(chatId).update({unreadField: 0});

    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: _currentUid)
        .get();

    if (unreadMessages.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // ⚙️ PRIVATE HELPERS
  // ---------------------------------------------------------------------------

  /// Updates the main chat document meta-data (last message, timestamp, unread counters).
  static Future<void> _updateChatPulse(
    String chatId,
    String lastMsg,
    String senderRole,
  ) async {
    final unreadField = (senderRole == 'driver')
        ? 'mechanicUnreadCount'
        : 'driverUnreadCount';

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': lastMsg,
      'lastMessageBy': _currentUid,
      'lastMessageTime': FieldValue.serverTimestamp(),
      unreadField: FieldValue.increment(1),
    });
  }

  /// Resolves the sender's name from the chat participant metadata.
  static Future<String> _resolveSenderName(String chatId, String role) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (!doc.exists) return (role == 'driver') ? 'Driver' : 'Mechanic';

      final data = doc.data()!;
      return (role == 'driver')
          ? (data['driverName'] ?? 'Driver')
          : (data['mechanicName'] ?? 'Mechanic');
    } catch (_) {
      return (role == 'driver') ? 'Driver' : 'Mechanic';
    }
  }

  /// Attempts to notify the recipient via mobile push notification.
  static void _dispatchNotification(
    String chatId,
    String role,
    String content,
    String senderName,
  ) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      final data = doc.data() ?? {};
      final recipientId = (role == 'driver')
          ? data['mechanicId']
          : data['driverId'];

      if (recipientId != null) {
        NotificationSender.notifyChatMessage(
          chatId: chatId,
          recipientId: recipientId,
          senderName: senderName,
          message: content,
        ).catchError((e) {});
      }
    } catch (e) {
      debugPrint('ChatService: failed to send chat notification: $e');
    }
  }
}
