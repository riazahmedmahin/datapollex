import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> languages;
  final double hourlyRate;
  final String bio;
  final List<String> specializations;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.languages,
    this.hourlyRate = 0.0,
    this.bio = '',
    this.specializations = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      languages: List<String>.from(map['languages'] ?? []),
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      bio: map['bio'] ?? '',
      specializations: List<String>.from(map['specializations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'languages': languages,
      'hourlyRate': hourlyRate,
      'bio': bio,
      'specializations': specializations,
    };
  }
}
