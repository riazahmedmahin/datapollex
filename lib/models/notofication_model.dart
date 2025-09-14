import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String teacherId;
  final String studentId;
  final String studentName;
  final String message;
  final String scheduleId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.studentName,
    required this.message,
    required this.scheduleId,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      message: map['message'] ?? '',
      scheduleId: map['scheduleId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'studentId': studentId,
      'studentName': studentName,
      'message': message,
      'scheduleId': scheduleId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}
