import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

/// User model representing all user types in the application
class UserModel extends Equatable {
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
  final List<String>? assignedStudents; // For teachers - list of student IDs

  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.age,
    this.photoUrl,
    required this.role,
    this.status = UserStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.preferredLevel,
    this.bio,
    this.teacherId,
    this.assignedStudents,
  });

  /// Empty user model
  static const empty = UserModel(
    id: '',
    name: '',
    role: UserRole.student,
    createdAt: '',
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'photoUrl': photoUrl,
      'role': role.value,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'preferredLevel': preferredLevel,
      'bio': bio,
      'teacherId': teacherId,
      'assignedStudents': assignedStudents,
    };
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      age: json['age'] as int?,
      photoUrl: json['photoUrl'] as String?,
      role: UserRole.fromString(json['role'] as String),
      status: UserStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      preferredLevel: json['preferredLevel'] as String?,
      bio: json['bio'] as String?,
      teacherId: json['teacherId'] as String?,
      assignedStudents: json['assignedStudents'] != null
          ? List<String>.from(json['assignedStudents'] as List)
          : null,
    );
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
  final String name;
  final String email;
  final String password;
  final String? phone;
  final int age;
  final String? preferredLevel;

  const StudentSignupRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.age,
    this.preferredLevel,
  });

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
  final String name;
  final String email;
  final String password;
  final String inviteCode;
  final String? phone;
  final String? bio;

  const TeacherSignupRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.inviteCode,
    this.phone,
    this.bio,
  });

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
