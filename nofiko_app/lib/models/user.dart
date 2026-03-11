// models/user.dart

import 'package:uuid/uuid.dart';

class UserRead {
  final String   id;
  final String   email;
  final String   userName;
  final bool     isActive;
  final DateTime createdAt;

  UserRead({
    required this.id,
    required this.email,
    required this.userName,
    required this.isActive,
    required this.createdAt,
  });

  factory UserRead.fromJson(Map<String, dynamic> json) {
    return UserRead(
      id:        json['id'],
      email:     json['email'],
      userName:  json['user_name'],
      isActive:  json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':         id,
    'email':      email,
    'user_name':  userName,
    'is_active':  isActive,
    'created_at': createdAt.toIso8601String(),
  };
}