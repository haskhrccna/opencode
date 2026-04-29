import 'package:equatable/equatable.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';

/// User model representing all user types in the application
class UserModel extends Equatable {
  // For teachers - list of student IDs

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.createdAt,
    this.email,
    this.phone,
    this.age,
    this.photoUrl,
    this.status = UserStatus.pending,
    this.updatedAt,
    this.preferredLevel,
    this.bio,
    this.teacherId,
    this.assignedStudents,
  });

  /// Create from a Supabase profiles row (snake_case keys)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      age: json['age'] as int?,
      photoUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String),
      status: UserStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      preferredLevel: json['preferred_level'] as String?,
      bio: json['bio'] as String?,
      teacherId: json['teacher_id'] as String?,
      assignedStudents: json['assigned_students'] != null
          ? List<String>.from(json['assigned_students'] as List)
          : null,
    );
  }
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final int? age;
  final String? photoUrl;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? preferredLevel;
  final String? bio;
  final String? teacherId; // For students - assigned teacher
  final List<String>? assignedStudents;

  /// Empty user model
  static final empty = UserModel(
    id: '',
    name: '',
    role: UserRole.student,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Check if user is empty
  bool get isEmpty => this == empty;

  /// Check if user is not empty
  bool get isNotEmpty => !isEmpty;

  /// Check if user is approved
  bool get isApproved => status == UserStatus.approved;

  /// Check if user is pending
  bool get isPending => status == UserStatus.pending;

  /// Check if user is rejected
  bool get isRejected => status == UserStatus.rejected;

  /// Check if user is suspended
  bool get isSuspended => status == UserStatus.suspended;

  /// Check if user is a student
  bool get isStudent => role == UserRole.student;

  /// Check if user is a teacher
  bool get isTeacher => role == UserRole.teacher;

  /// Check if user is an admin
  bool get isAdmin => role == UserRole.admin;

  /// Convert to JSON for Supabase (snake_case keys)
  /// Note: assigned_students is not a column — query teacher_students table instead
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'avatar_url': photoUrl,
      'role': role.value,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'preferred_level': preferredLevel,
      'bio': bio,
      'teacher_id': teacherId,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? age,
    String? photoUrl,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? preferredLevel,
    String? bio,
    String? teacherId,
    List<String>? assignedStudents,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferredLevel: preferredLevel ?? this.preferredLevel,
      bio: bio ?? this.bio,
      teacherId: teacherId ?? this.teacherId,
      assignedStudents: assignedStudents ?? this.assignedStudents,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        age,
        photoUrl,
        role,
        status,
        createdAt,
        updatedAt,
        preferredLevel,
        bio,
        teacherId,
        assignedStudents,
      ];

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, role: $role, status: $status)';
  }
}

/// Student signup request
class StudentSignupRequest {
  const StudentSignupRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    this.phone,
    this.preferredLevel,
  });
  final String name;
  final String email;
  final String password;
  final String? phone;
  final int age;
  final String? preferredLevel;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'preferredLevel': preferredLevel,
    };
  }
}

/// Teacher signup request
class TeacherSignupRequest {
  const TeacherSignupRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.inviteCode,
    this.phone,
    this.bio,
  });
  final String name;
  final String email;
  final String password;
  final String inviteCode;
  final String? phone;
  final String? bio;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'inviteCode': inviteCode,
    };
  }
}
