import 'package:equatable/equatable.dart';

import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  uploading,
  error,
}

class ProfileState extends Equatable {
  const ProfileState({
    required this.status,
    this.profile,
    this.teachers,
    this.students,
    this.errorMessage,
    this.lastUpdated,
  });

  factory ProfileState.initial() => const ProfileState(
        status: ProfileStatus.initial,
      );
  final ProfileStatus status;
  final UserProfile? profile;
  final List<UserProfile>? teachers;
  final List<UserProfile>? students;
  final String? errorMessage;
  final DateTime? lastUpdated;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<UserProfile>? teachers,
    List<UserProfile>? students,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      teachers: teachers ?? this.teachers,
      students: students ?? this.students,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        teachers,
        students,
        errorMessage,
        lastUpdated,
      ];
}
