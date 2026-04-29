import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';
import 'package:quran_tutor_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:quran_tutor_app/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:quran_tutor_app/features/profile/domain/usecases/update_profile_usecase.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _FakeFile extends Fake implements File {}

class _FakeUserProfile extends Fake implements UserProfile {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUserProfile());
    registerFallbackValue(_FakeFile());
  });

  late _MockProfileRepository repo;

  setUp(() {
    repo = _MockProfileRepository();
  });

  final tProfile = UserProfile(
    id: 'u-1',
    email: 'a@b.co',
    role: UserRole.student,
    status: UserStatus.approved,
    createdAt: DateTime.utc(2026, 4, 29),
  );

  group('GetProfileUseCase', () {
    test('returns profile on success', () async {
      when(() => repo.getCurrentProfile())
          .thenAnswer((_) async => (tProfile, null));
      final useCase = GetProfileUseCase(repo);

      final (profile, failure) = await useCase();

      expect(profile, tProfile);
      expect(failure, isNull);
      verify(() => repo.getCurrentProfile()).called(1);
    });

    test('propagates failure', () async {
      final f = ServerFailure.internalError();
      when(() => repo.getCurrentProfile())
          .thenAnswer((_) async => (null, f));
      final useCase = GetProfileUseCase(repo);

      final (profile, failure) = await useCase();
      expect(profile, isNull);
      expect(failure, f);
    });
  });

  group('GetProfileByIdUseCase', () {
    test('forwards id', () async {
      when(() => repo.getProfileById(any()))
          .thenAnswer((_) async => (tProfile, null));
      final useCase = GetProfileByIdUseCase(repo);

      final (profile, _) = await useCase('u-2');
      expect(profile, tProfile);
      verify(() => repo.getProfileById('u-2')).called(1);
    });
  });

  group('UpdateProfileUseCase', () {
    test('forwards profile and returns success', () async {
      when(() => repo.updateProfile(any()))
          .thenAnswer((_) async => (tProfile, null));
      final useCase = UpdateProfileUseCase(repo);

      final (profile, failure) = await useCase(tProfile);

      expect(profile, tProfile);
      expect(failure, isNull);
      verify(() => repo.updateProfile(tProfile)).called(1);
    });
  });

  group('UploadAvatarUseCase', () {
    test('forwards file and returns updated profile', () async {
      when(() => repo.uploadAvatar(any()))
          .thenAnswer((_) async => (tProfile, null));
      final useCase = UploadAvatarUseCase(repo);
      final fakeFile = _FakeFile();

      final (profile, failure) = await useCase(fakeFile);

      expect(profile, tProfile);
      expect(failure, isNull);
      verify(() => repo.uploadAvatar(fakeFile)).called(1);
    });
  });

  group('DeleteAvatarUseCase', () {
    test('returns null on success', () async {
      when(() => repo.deleteAvatar()).thenAnswer((_) async => null);
      final useCase = DeleteAvatarUseCase(repo);

      final failure = await useCase();
      expect(failure, isNull);
    });

    test('propagates failure', () async {
      final f = ServerFailure.internalError();
      when(() => repo.deleteAvatar()).thenAnswer((_) async => f);
      final useCase = DeleteAvatarUseCase(repo);

      final failure = await useCase();
      expect(failure, f);
    });
  });
}
