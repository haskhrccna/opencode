import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_profile.dart';

part 'profile_state.freezed.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  uploading,
  error,
}

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    required ProfileStatus status,
    UserProfile? profile,
    List<UserProfile>? teachers,
    List<UserProfile>? students,
    String? errorMessage,
    DateTime? lastUpdated,
  }) = _ProfileState;

  factory ProfileState.initial() => const ProfileState(
        status: ProfileStatus.initial,
      );
}
