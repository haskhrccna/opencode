import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/auth_user.dart';

/// User model for authentication
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? arabicName;
  final String? photoUrl;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? teacherId;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.arabicName,
    this.photoUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.phoneNumber,
    this.dateOfBirth,
    this.teacherId,
  });

  /// Factory constructor from JSON (snake_case keys from Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['name'] as String?,
      arabicName: json['arabic_name'] as String?,
      photoUrl: json['avatar_url'] as String? ?? json['photo_url'] as String?,
      role: json['role'] as String? ?? 'student',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      phoneNumber: json['phone_number'] as String? ?? json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      teacherId: json['teacher_id'] as String?,
    );
  }

  /// Factory constructor from Supabase user
  factory UserModel.fromSupabaseUser(User user, Map<String, dynamic>? profileData) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: profileData?['display_name'] as String? ??
          profileData?['name'] as String? ??
          user.userMetadata?['name'] as String?,
      arabicName: profileData?['arabic_name'] as String?,
      photoUrl: profileData?['avatar_url'] as String? ??
          user.userMetadata?['avatar_url'] as String?,
      role: profileData?['role'] as String? ?? 'student',
      status: profileData?['status'] as String? ?? 'pending',
createdAt: DateTime.parse(user.createdAt),
      updatedAt: user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
      phoneNumber: profileData?['phone_number'] as String? ??
          profileData?['phone'] as String?,
      dateOfBirth: profileData?['date_of_birth'] != null
          ? DateTime.parse(profileData!['date_of_birth'] as String)
          : null,
      teacherId: profileData?['teacher_id'] as String?,
    );
  }

  /// Convert to JSON (snake_case for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'arabic_name': arabicName,
      'avatar_url': photoUrl,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'teacher_id': teacherId,
    };
  }

  /// Convert to Supabase JSON format (same as toJson)
  Map<String, dynamic> toSupabaseJson() => toJson();

  /// Convert to domain entity
  AuthUser toEntity() {
    return AuthUser(
      id: id,
      email: email,
      displayName: displayName,
      arabicName: arabicName,
      photoUrl: photoUrl,
      role: UserRole.fromString(role),
      status: UserStatus.fromString(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      teacherId: teacherId,
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(AuthUser user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      arabicName: user.arabicName,
      photoUrl: user.photoUrl,
      role: user.role.value,
      status: user.status.value,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      phoneNumber: user.phoneNumber,
      dateOfBirth: user.dateOfBirth,
      teacherId: user.teacherId,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? arabicName,
    String? photoUrl,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? teacherId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      arabicName: arabicName ?? this.arabicName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}
