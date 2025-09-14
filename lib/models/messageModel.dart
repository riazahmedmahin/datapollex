import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderEmail;
  final String message;
  final DateTime timestamp;
  final String type;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
    required this.type,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'text',
    );
  }
}
