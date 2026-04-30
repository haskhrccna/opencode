import 'package:equatable/equatable.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';

/// Domain entity representing an authenticated user
///
/// This is decoupled from UserModel and contains only
/// the fields needed for authentication and authorization.
class AuthUser extends Equatable {
  // For students - references their teacher

  const AuthUser({
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
  });

  /// Create an empty/unauthenticated user
  factory AuthUser.empty() => AuthUser(
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

  /// Check if user is authenticated
  bool get isAuthenticated => id.isNotEmpty && email.isNotEmpty;

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is teacher
  bool get isTeacher => role == UserRole.teacher;

  /// Check if user is student
  bool get isStudent => role == UserRole.student;

  /// Check if user is approved
  bool get isApproved => status == UserStatus.approved;

  /// Check if user is pending approval
  bool get isPending => status == UserStatus.pending;

  /// Check if user is rejected
  bool get isRejected => status == UserStatus.rejected;

  /// Check if user is suspended
  bool get isSuspended => status == UserStatus.suspended;

  /// Get localized role name
  String getRoleLabel(String languageCode) {
    if (languageCode == 'ar') {
      return role.arabicLabel;
    }
    return role.value;
  }

  /// Get localized status name
  String getStatusLabel(String languageCode) {
    if (languageCode == 'ar') {
      return status.arabicLabel;
    }
    return status.value;
  }

  AuthUser copyWith({
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
  }) {
    return AuthUser(
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
      ];

  @override
  String toString() =>
      'AuthUser(id: $id, email: $email, role: ${role.value}, status: ${status.value})';
}
