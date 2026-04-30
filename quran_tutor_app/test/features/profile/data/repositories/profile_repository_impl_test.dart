import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:quran_tutor_app/features/profile/data/models/profile_model.dart';
import 'package:quran_tutor_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(
      ProfileModel(
        id: '',
        email: '',
        role: 'student',
        status: 'approved',
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  final tProfileModel = ProfileModel(
    id: 'user-1',
    email: 'test@example.com',
    role: 'student',
    status: 'approved',
    createdAt: DateTime.now(),
    displayName: 'Test User',
    arabicName: 'مستخدم تجريبي',
    phoneNumber: '0501234567',
  );

  group('getCurrentProfile', () {
    test('should return UserProfile on success', () async {
      when(() => mockRemoteDataSource.getCurrentProfile())
          .thenAnswer((_) async => tProfileModel);

      final (profile, failure) = await repository.getCurrentProfile();

      expect(profile, isNotNull);
      expect(profile!.email, 'test@example.com');
      expect(failure, isNull);
      verify(() => mockRemoteDataSource.getCurrentProfile()).called(1);
    });

    test('should return AuthFailure when no current user', () async {
      when(() => mockRemoteDataSource.getCurrentProfile())
          .thenAnswer((_) async => null);

      final (profile, failure) = await repository.getCurrentProfile();

      expect(profile, isNull);
      expect(failure, isA<AuthFailure>());
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => mockRemoteDataSource.getCurrentProfile())
          .thenThrow(ServerException.internalError());

      final (profile, failure) = await repository.getCurrentProfile();

      expect(profile, isNull);
      expect(failure, isA<ServerFailure>());
    });
  });

  group('getProfileById', () {
    const tUserId = 'user-1';

    test('should return UserProfile on success', () async {
      when(() => mockRemoteDataSource.getProfile(tUserId))
          .thenAnswer((_) async => tProfileModel);

      final (profile, failure) = await repository.getProfileById(tUserId);

      expect(profile, isNotNull);
      expect(profile!.id, tUserId);
      expect(failure, isNull);
    });

    test('should return ServerFailure.notFound when profile is null', () async {
      when(() => mockRemoteDataSource.getProfile(tUserId))
          .thenAnswer((_) async => null);

      final (profile, failure) = await repository.getProfileById(tUserId);

      expect(profile, isNull);
      expect(failure, isA<ServerFailure>());
    });
  });

  group('updateProfile', () {
    test('should return updated UserProfile on success', () async {
      final updatedModel = tProfileModel.copyWith(displayName: 'Updated Name');
      final entity =
          tProfileModel.toEntity().copyWith(displayName: 'Updated Name');

      when(() => mockRemoteDataSource.updateProfile(any()))
          .thenAnswer((_) async => updatedModel);

      final (profile, failure) = await repository.updateProfile(entity);

      expect(profile, isNotNull);
      expect(profile!.displayName, 'Updated Name');
      expect(failure, isNull);
    });
  });

  group('getTeachers', () {
    test('should return list of teachers on success', () async {
      final teacherModel = tProfileModel.copyWith(role: 'teacher');
      when(() => mockRemoteDataSource.getTeachers())
          .thenAnswer((_) async => [teacherModel]);

      final (teachers, failure) = await repository.getTeachers();

      expect(teachers, isNotNull);
      expect(teachers!.length, 1);
      expect(teachers.first.role, UserRole.teacher);
      expect(failure, isNull);
    });
  });

  group('getStudentsByTeacher', () {
    const tTeacherId = 'teacher-1';

    test('should return list of students on success', () async {
      when(() => mockRemoteDataSource.getStudentsByTeacher(tTeacherId))
          .thenAnswer((_) async => [tProfileModel]);

      final (students, failure) =
          await repository.getStudentsByTeacher(tTeacherId);

      expect(students, isNotNull);
      expect(students!.length, 1);
      expect(failure, isNull);
    });
  });

  group('linkStudentToTeacher', () {
    test('should return null on success', () async {
      when(() => mockRemoteDataSource.linkStudentToTeacher(
          'student-1', 'teacher-1')).thenAnswer((_) async {});

      final failure = await repository.linkStudentToTeacher(
        studentId: 'student-1',
        teacherId: 'teacher-1',
      );

      expect(failure, isNull);
    });
  });

  group('unlinkStudentFromTeacher', () {
    test('should return null on success', () async {
      when(() => mockRemoteDataSource.unlinkStudentFromTeacher('student-1'))
          .thenAnswer((_) async {});

      final failure = await repository.unlinkStudentFromTeacher('student-1');

      expect(failure, isNull);
    });
  });
}
