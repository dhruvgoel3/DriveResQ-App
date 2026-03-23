import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'driver' or 'mechanic'
  final String type; // 'text', 'image', 'voice', 'price_quote', 'system'
  final String content;
  final String? imageUrl;
  final String? audioUrl;
  final int? audioDuration; // seconds
  final Map<String, dynamic>? priceData;
  final Timestamp timestamp;
  final bool read;
  final bool delivered;

  MessageModel({
    required this.id,
    required this.senderId,
    this.senderName = '',
    required this.senderRole,
    required this.type,
    required this.content,
    this.imageUrl,
    this.audioUrl,
    this.audioDuration,
    this.priceData,
    required this.timestamp,
    this.read = false,
    this.delivered = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? '',
      type: map['type'] ?? 'text',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      audioDuration: map['audioDuration'],
      priceData: map['priceData'],
      timestamp: map['timestamp'] ?? Timestamp.now(),
      read: map['read'] ?? false,
      delivered: map['delivered'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'type': type,
      'content': content,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'audioDuration': audioDuration,
      'priceData': priceData,
      'timestamp': timestamp,
      'read': read,
      'delivered': delivered,
    };
  }
}
