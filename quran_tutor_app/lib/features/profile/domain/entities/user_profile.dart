import 'package:equatable/equatable.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';

/// Extended user profile entity with detailed information
///
/// This is separate from AuthUser and contains additional
/// profile information not needed for authentication.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    this.displayName,
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

  /// Create empty profile
  factory UserProfile.empty() => UserProfile(
        id: '',
        email: '',
        role: UserRole.student,
        status: UserStatus.pending,
        createdAt: DateTime.now(),
      );
  final String id;
  final String email;
  final String? displayName;
  final String? arabicName;
  final String? photoUrl;
  final UserRole role;
  final UserStatus status;
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

  /// Get display name (Arabic preferred, fallback to English)
  String get displayNameOrEmail =>
      arabicName ?? displayName ?? email.split('@').first;

  /// Calculate age
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    return now.year -
        dateOfBirth!.year -
        (now.month < dateOfBirth!.month ||
                (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)
            ? 1
            : 0);
  }

  /// Check if has avatar
  bool get hasAvatar => photoUrl != null && photoUrl!.isNotEmpty;

  /// Get initials for avatar placeholder
  String get initials {
    final name = displayName ?? arabicName ?? email;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? arabicName,
    String? photoUrl,
    UserRole? role,
    UserStatus? status,
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
    return UserProfile(
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

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        arabicName,
        photoUrl,
        role,
        status,
        createdAt,
        updatedAt,
        phoneNumber,
        dateOfBirth,
        teacherId,
        bio,
        websiteUrl,
        address,
        emergencyContact,
        preferences,
        sessionsCompleted,
        sessionsScheduled,
      ];
}
