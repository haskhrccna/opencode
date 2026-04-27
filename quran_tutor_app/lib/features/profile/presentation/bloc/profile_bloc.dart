import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(ProfileState.initial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LoadProfileById>(_onLoadProfileById);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
    on<DeleteAvatar>(_onDeleteAvatar);
    on<UpdatePassword>(_onUpdatePassword);
    on<LoadTeachers>(_onLoadTeachers);
    on<LoadStudentsByTeacher>(_onLoadStudentsByTeacher);
    on<LinkStudentToTeacher>(_onLinkStudentToTeacher);
    on<UnlinkStudentFromTeacher>(_onUnlinkStudentFromTeacher);
    on<RefreshProfile>(_onRefreshProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final (profile, failure) = await _repository.getCurrentProfile();

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadProfileById(
    LoadProfileById event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final (profile, failure) = await _repository.getProfileById(event.userId);

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    final currentProfile = state.profile;
    if (currentProfile == null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'No profile loaded',
      ));
      return;
    }

    // Create updated profile
    final updatedProfile = currentProfile.copyWith(
      arabicName: event.arabicName,
      displayName: event.englishName,
      phoneNumber: event.phoneNumber,
      bio: event.bio,
      websiteUrl: event.websiteUrl,
      dateOfBirth: event.dateOfBirth,
    );

    final (profile, failure) = await _repository.updateProfile(updatedProfile);

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.uploading));

    final (profile, failure) = await _repository.uploadAvatar(event.imageFile);

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onDeleteAvatar(
    DeleteAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    final failure = await _repository.deleteAvatar();

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      // Refresh profile
      add(const LoadProfile());
    }
  }

  Future<void> _onUpdatePassword(
    UpdatePassword event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    final failure = await _repository.updatePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadTeachers(
    LoadTeachers event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final (teachers, failure) = await _repository.getTeachers();

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        teachers: teachers,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadStudentsByTeacher(
    LoadStudentsByTeacher event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final (students, failure) = await _repository.getStudentsByTeacher(event.teacherId);

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        students: students,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLinkStudentToTeacher(
    LinkStudentToTeacher event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    final failure = await _repository.linkStudentToTeacher(
      studentId: event.studentId,
      teacherId: event.teacherId,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      // Refresh students list
      add(LoadStudentsByTeacher(event.teacherId));
    }
  }

  Future<void> _onUnlinkStudentFromTeacher(
    UnlinkStudentFromTeacher event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    final failure = await _repository.unlinkStudentFromTeacher(event.studentId);

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      // Refresh profile
      add(const LoadProfile());
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final (profile, failure) = await _repository.getCurrentProfile();

    if (failure != null) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        lastUpdated: DateTime.now(),
      ));
    }
  }
}
