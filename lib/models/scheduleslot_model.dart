import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleSlot {
  final String id;
  final String teacherId;
  final String teacherName;
  final DateTime dateTime;
  final int duration;
  final String language;
  final double price;
  final bool isBooked;
  final String? studentId;
  final String? studentName;
  final String status;
  final String? courseName;

  ScheduleSlot({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.dateTime,
    required this.duration,
    required this.language,
    required this.price,
    this.isBooked = false,
    this.studentId,
    this.studentName,
    this.status = 'accepted',
    this.courseName,
  });

  factory ScheduleSlot.fromMap(Map<String, dynamic> map) {
    return ScheduleSlot(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      dateTime:
          map['dateTime'] is String
              ? DateTime.parse(map['dateTime'])
              : (map['dateTime'] as Timestamp).toDate(),
      duration: map['duration'] ?? 60,
      language: map['language'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      isBooked: map['isBooked'] ?? false,
      studentId: map['studentId'],
      studentName: map['studentName'],
      status: map['status'] ?? 'available',
      courseName: map['courseName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'dateTime': Timestamp.fromDate(dateTime),
      'duration': duration,
      'language': language,
      'price': price,
      'isBooked': isBooked,
      'studentId': studentId,
      'studentName': studentName,
      'status': status,
      'courseName': courseName,
    };
  }
}
