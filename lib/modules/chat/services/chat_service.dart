import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../notifications/services/notification_sender.dart';
import '../models/message_model.dart';

class ChatService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser?.uid ?? '';

  // ─── Resolve sender name from the chat document ───
  static Future<String> _resolveSenderName(
    String chatId,
    String senderRole,
  ) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (senderRole == 'driver') {
          return data['driverName'] ?? 'Driver';
        } else {
          return data['mechanicName'] ?? 'Mechanic';
        }
      }
    } catch (_) {}
    return senderRole == 'driver' ? 'Driver' : 'Mechanic';
  }

  // ─── Create or get chat for a request ───
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

    // Attempt to resolve real names if generic or missing
    String finalDriverName = driverName ?? 'Driver';
    String finalMechanicName = mechanicName ?? 'Mechanic';
    String finalDriverPhoto = driverPhoto ?? '';
    String finalMechanicPhoto = mechanicPhoto ?? '';

    try {
      if (finalDriverName == 'Driver' || finalDriverName.isEmpty) {
        final dDoc = await _firestore.collection('users').doc(driverId).get();
        if (dDoc.exists) {
          final data = dDoc.data()!;
          finalDriverName = data['fullName'] ?? data['name'] ?? 'Driver';
          finalDriverPhoto =
              data['profilePhotoUrl'] ?? data['photoUrl'] ?? finalDriverPhoto;
        }
      }

      if (finalMechanicName == 'Mechanic' || finalMechanicName.isEmpty) {
        final mDoc = await _firestore.collection('users').doc(mechanicId).get();
        if (mDoc.exists) {
          final data = mDoc.data()!;
          finalMechanicName = data['fullName'] ?? data['name'] ?? 'Mechanic';
          finalMechanicPhoto =
              data['profilePhotoUrl'] ?? data['photoUrl'] ?? finalMechanicPhoto;
        }
      }
    } catch (e) {
      // Ignore errors, fallback to whatever was passed
    }

    await chatRef.set({
      'participants': FieldValue.arrayUnion([driverId, mechanicId]),
      'driverId': driverId,
      'mechanicId': mechanicId,
      'driverName': finalDriverName,
      'mechanicName': finalMechanicName,
      'driverPhoto': finalDriverPhoto,
      'mechanicPhoto': finalMechanicPhoto,
      'lastMessage': 'Chat started',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageBy': '',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Send a system message
    await sendSystemMessage(
      requestId,
      '🤝 Chat started! You can discuss the service details here.',
    );
  }

  // ─── Send text message ───
  static Future<void> sendMessage({
    required String chatId,
    required String content,
    required String senderRole,
  }) async {
    final senderName = await _resolveSenderName(chatId, senderRole);

    final msg = {
      'senderId': _uid,
      'senderName': senderName,
      'senderRole': senderRole,
      'type': 'text',
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'delivered': true,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(msg);

    // Update chat doc
    final unreadField = senderRole == 'driver'
        ? 'mechanicUnreadCount'
        : 'driverUnreadCount';
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageBy': _uid,
      unreadField: FieldValue.increment(1),
    }, SetOptions(merge: true));

    // 🔔 Notify recipient
    await _sendNotification(
      chatId: chatId,
      senderRole: senderRole,
      content: content,
    );
  }

  // ─── Send system message ───
  static Future<void> sendSystemMessage(String chatId, String content) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': 'system',
          'senderName': 'System',
          'senderRole': 'system',
          'type': 'system',
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'delivered': true,
        });

    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageBy': 'system',
    }, SetOptions(merge: true));
  }

  // ─── Send image message ───
  static Future<void> sendImageFromPath({
    required String chatId,
    required String imagePath,
    required String senderRole,
    String caption = '',
  }) async {
    final senderName = await _resolveSenderName(chatId, senderRole);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref('chats/$chatId/images/$fileName');

    // Upload
    if (kIsWeb) {
      final bytes = await XFileHelper.readBytes(imagePath);
      if (bytes != null) {
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      }
    } else {
      await _uploadFileNative(ref, imagePath);
    }

    final url = await ref.getDownloadURL();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': _uid,
          'senderName': senderName,
          'senderRole': senderRole,
          'type': 'image',
          'content': caption,
          'imageUrl': url,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'delivered': true,
        });

    final unreadField = senderRole == 'driver'
        ? 'mechanicUnreadCount'
        : 'driverUnreadCount';
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': '📷 Photo',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageBy': _uid,
      unreadField: FieldValue.increment(1),
    }, SetOptions(merge: true));

    // 🔔 Notify recipient
    await _sendNotification(
      chatId: chatId,
      senderRole: senderRole,
      content: '📷 Photo',
    );
  }

  // ─── Send voice message ───
  static Future<void> sendVoiceMessage({
    required String chatId,
    required String audioPath,
    required String senderRole,
    required int durationSeconds,
  }) async {
    final senderName = await _resolveSenderName(chatId, senderRole);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ref = _storage.ref('chats/$chatId/voice/$fileName');

    // Check local file
    final file = File(audioPath);
    if (!await file.exists()) {
      throw Exception('Recording file not found locally: $audioPath');
    }

    // Upload audio file
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'audio/m4a'),
    );
    final snapshot = await uploadTask;

    if (snapshot.state != TaskState.success) {
      throw Exception('Failed to upload voice message');
    }

    final url = await ref.getDownloadURL();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': _uid,
          'senderName': senderName,
          'senderRole': senderRole,
          'type': 'voice',
          'content': '',
          'audioUrl': url,
          'audioDuration': durationSeconds,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'delivered': true,
        });

    final unreadField = senderRole == 'driver'
        ? 'mechanicUnreadCount'
        : 'driverUnreadCount';
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': '🎤 Voice message',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageBy': _uid,
      unreadField: FieldValue.increment(1),
    }, SetOptions(merge: true));

    // 🔔 Notify recipient
    await _sendNotification(
      chatId: chatId,
      senderRole: senderRole,
      content: '🎤 Voice message',
    );
  }

  static Future<void> _uploadFileNative(Reference ref, String path) async {
    try {
      final file = await _createFile(path);
      if (file != null) {
        await ref.putData(file);
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    }
  }

  static Future<Uint8List?> _createFile(String path) async {
    try {
      final xFile = XFileHelper.fromPath(path);
      return await xFile.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  // ─── Send price quote ───
  static Future<void> sendPriceQuote({
    required String chatId,
    required String service,
    required double estimatedCost,
    required String estimatedTime,
    String? notes,
    List<String>? parts,
  }) async {
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
          'senderId': _uid,
          'senderName': await _resolveSenderName(chatId, 'mechanic'),
          'senderRole': 'mechanic',
          'type': 'price_quote',
          'content': 'Service Estimate',
          'priceData': priceData,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'delivered': true,
        });

    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage':
          '💰 Sent an estimate: ₹${estimatedCost.toStringAsFixed(0)}',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageBy': _uid,
      'driverUnreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    // 🔔 Notify recipient
    await _sendNotification(
      chatId: chatId,
      senderRole: 'mechanic',
      content: '💰 Sent an estimate: ₹${estimatedCost.toStringAsFixed(0)}',
    );
  }

  // ─── Respond to price quote ───
  static Future<void> respondToPriceQuote({
    required String chatId,
    required String messageId,
    required String response,
    double? counterOffer,
    String? reason,
  }) async {
    final msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final doc = await msgRef.get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final priceData = Map<String, dynamic>.from(data['priceData'] ?? {});
    priceData['status'] = response;
    if (counterOffer != null) priceData['counterOffer'] = counterOffer;
    if (reason != null) priceData['reason'] = reason;

    await msgRef.update({'priceData': priceData});

    if (response == 'accepted') {
      final cost = priceData['estimatedCost'] ?? 0;
      await _firestore.collection('chats').doc(chatId).set({
        'priceAgreed': cost,
      }, SetOptions(merge: true));
      await sendSystemMessage(
        chatId,
        '✅ Price agreed: ₹${(cost as num).toStringAsFixed(0)}',
      );
    } else if (response == 'rejected') {
      await sendSystemMessage(
        chatId,
        '❌ Estimate declined${reason != null ? ': $reason' : ''}',
      );
    } else if (response == 'negotiated') {
      await sendSystemMessage(
        chatId,
        '💬 Counter offer: ₹${counterOffer?.toStringAsFixed(0) ?? '—'}${reason != null ? ' — $reason' : ''}',
      );
    }
  }

  // ─── Mark messages as read ───
  static Future<void> markAsRead(String chatId, String role) async {
    final unreadField = role == 'driver'
        ? 'driverUnreadCount'
        : 'mechanicUnreadCount';

    await _firestore.collection('chats').doc(chatId).update({unreadField: 0});

    // Mark individual messages
    final unread = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: _uid)
        .get();

    final batch = _firestore.batch();
    for (var doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  // ─── Messages stream ───
  static Stream<List<MessageModel>> messagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MessageModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  // ─── User's chats stream ───
  static Stream<QuerySnapshot> userChatsStream() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: _uid)
        .snapshots();
  }

  // ─── Helper for Notifications ───
  static Future<void> _sendNotification({
    required String chatId,
    required String senderRole,
    required String content,
  }) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        final chatData = doc.data()!;
        final recipientId = senderRole == 'driver'
            ? chatData['mechanicId']
            : chatData['driverId'];
        final senderName = senderRole == 'driver'
            ? (chatData['driverName'] ?? 'Driver')
            : (chatData['mechanicName'] ?? 'Mechanic');

        if (recipientId != null && recipientId.toString().isNotEmpty) {
          await NotificationSender.notifyChatMessage(
            chatId: chatId,
            recipientId: recipientId,
            senderName: senderName,
            message: content,
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending chat notification: $e');
    }
  }
}

// Helper class for cross-platform file handling
class XFileHelper {
  static Future<Uint8List?> readBytes(String path) async {
    try {
      final xFile = fromPath(path);
      return await xFile.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  static dynamic fromPath(String path) {
    return _XFileLite(path);
  }
}

class _XFileLite {
  final String path;

  _XFileLite(this.path);

  Future<Uint8List> readAsBytes() async {
    final xFile = await _getXFile();
    return await xFile.readAsBytes();
  }

  Future<dynamic> _getXFile() async {
    return this;
  }
}
