import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';

/// Data model for user profile
class ProfileModel {

  ProfileModel({
    required this.id,
    required this.email,
    required this.role, required this.status, required this.createdAt, this.displayName,
    this.arabicName,
    this.photoUrl,
    this.updatedAt,
    this.phoneNumber,
    this.dateOfBirth,
    this.teacherId,
    this.bio,
    this.websiteUrl,
    this.address,
    this.emergencyContact,
    this.preferences,
    this.sessionsCompleted,
    this.sessionsScheduled,
  });

  factory ProfileModel.fromSupabase(Map<String, dynamic> data) {
    return ProfileModel(
      id: (data['id'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      displayName: data['display_name'] as String?,
      arabicName: data['arabic_name'] as String?,
      photoUrl: data['photo_url'] as String?,
      role: (data['role'] as String?) ?? 'student',
      status: (data['status'] as String?) ?? 'pending',
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
      phoneNumber: data['phone_number'] as String?,
      dateOfBirth: data['date_of_birth'] != null
          ? DateTime.parse(data['date_of_birth'] as String)
          : null,
      teacherId: data['teacher_id'] as String?,
      bio: data['bio'] as String?,
      websiteUrl: data['website_url'] as String?,
      address: data['address'] as String?,
      emergencyContact: data['emergency_contact'] as String?,
      preferences: data['preferences'] as Map<String, dynamic>?,
      sessionsCompleted: (data['sessions_completed'] as num?)?.toInt(),
      sessionsScheduled: (data['sessions_scheduled'] as num?)?.toInt(),
    );
  }

  factory ProfileModel.fromEntity(UserProfile entity) {
    return ProfileModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      arabicName: entity.arabicName,
      photoUrl: entity.photoUrl,
      role: entity.role.value,
      status: entity.status.value,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      phoneNumber: entity.phoneNumber,
      dateOfBirth: entity.dateOfBirth,
      teacherId: entity.teacherId,
      bio: entity.bio,
      websiteUrl: entity.websiteUrl,
      address: entity.address,
      emergencyContact: entity.emergencyContact,
      preferences: entity.preferences,
      sessionsCompleted: entity.sessionsCompleted,
      sessionsScheduled: entity.sessionsScheduled,
    );
  }
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
  final String? bio;
  final String? websiteUrl;
  final String? address;
  final String? emergencyContact;
  final Map<String, dynamic>? preferences;
  final int? sessionsCompleted;
  final int? sessionsScheduled;

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'arabic_name': arabicName,
      'photo_url': photoUrl,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'teacher_id': teacherId,
      'bio': bio,
      'website_url': websiteUrl,
      'address': address,
      'emergency_contact': emergencyContact,
      'preferences': preferences,
      'sessions_completed': sessionsCompleted,
      'sessions_scheduled': sessionsScheduled,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
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
      bio: bio,
      websiteUrl: websiteUrl,
      address: address,
      emergencyContact: emergencyContact,
      preferences: preferences,
      sessionsCompleted: sessionsCompleted,
      sessionsScheduled: sessionsScheduled,
    );
  }

  ProfileModel copyWith({
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
    String? bio,
    String? websiteUrl,
    String? address,
    String? emergencyContact,
    Map<String, dynamic>? preferences,
    int? sessionsCompleted,
    int? sessionsScheduled,
  }) {
    return ProfileModel(
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
      bio: bio ?? this.bio,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      preferences: preferences ?? this.preferences,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      sessionsScheduled: sessionsScheduled ?? this.sessionsScheduled,
    );
  }
}
