import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/auth_user.dart';

/// Data model representing a user from Supabase/Firebase
///
/// This model handles serialization/deserialization
/// and maps to the domain entity AuthUser.
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
  final Map<String, dynamic>? metadata;

  const UserModel({
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
    this.metadata,
  });

  /// Create from Supabase user
  factory UserModel.fromSupabase(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      arabicName: json['arabic_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      role: json['role'] as String? ?? 'student',
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      teacherId: json['teacher_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Create from Firebase user document
  factory UserModel.fromFirebase(String uid, Map<String, dynamic> json) {
    return UserModel(
      id: uid,
      email: json['email'] as String,
      displayName: json['displayName'] as String? ?? json['name'] as String?,
      arabicName: json['arabicName'] as String? ?? json['arabic_name'] as String?,
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String?,
      role: json['role'] as String? ?? 'student',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as dynamic).toDate()
          : null,
      phoneNumber: json['phoneNumber'] as String? ?? json['phone_number'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? (json['dateOfBirth'] as dynamic).toDate()
          : null,
      teacherId: json['teacherId'] as String? ?? json['teacher_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

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

  /// Convert to Supabase JSON
  Map<String, dynamic> toSupabaseJson() {
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
      'metadata': metadata,
    };
  }

  /// Convert to Firebase JSON
  Map<String, dynamic> toFirebaseJson() {
    return {
      'email': email,
      'displayName': displayName,
      'arabicName': arabicName,
      'photoUrl': photoUrl,
      'role': role,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'teacherId': teacherId,
      'metadata': metadata,
    };
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
    Map<String, dynamic>? metadata,
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
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, email: $email, role: $role)';
}
