import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:quran_tutor_app/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:quran_tutor_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:quran_tutor_app/features/auth/data/models/user_model.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';

class MockAdminRemoteDataSource extends Mock implements AdminRemoteDataSource {}

void main() {
  late AdminRepositoryImpl repository;
  late MockAdminRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAdminRemoteDataSource();
    repository = AdminRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('getPendingUsers', () {
    final tUserModels = [
      UserModel(
        id: '1',
        email: 'student@example.com',
        role: 'student',
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    ];

    test('should return list of pending users on success', () async {
      when(() => mockRemoteDataSource.getPendingUsers())
          .thenAnswer((_) async => tUserModels);

      final (users, failure) = await repository.getPendingUsers();

      expect(users, isNotNull);
      expect(users!.length, 1);
      expect(users.first.email, 'student@example.com');
      expect(failure, isNull);
      verify(() => mockRemoteDataSource.getPendingUsers()).called(1);
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => mockRemoteDataSource.getPendingUsers())
          .thenThrow(ServerException.internalError());

      final (users, failure) = await repository.getPendingUsers();

      expect(users, isNull);
      expect(failure, isA<ServerFailure>());
    });

    test('should return NetworkFailure on NetworkException', () async {
      when(() => mockRemoteDataSource.getPendingUsers())
          .thenThrow(NetworkException.noConnection());

      final (users, failure) = await repository.getPendingUsers();

      expect(users, isNull);
      expect(failure, isA<NetworkFailure>());
    });
  });

  group('approveUser', () {
    const tUserId = 'user-123';

    test('should return null on success', () async {
      when(() => mockRemoteDataSource.approveUser(tUserId))
          .thenAnswer((_) async {});

      final failure = await repository.approveUser(tUserId);

      expect(failure, isNull);
      verify(() => mockRemoteDataSource.approveUser(tUserId)).called(1);
    });

    test('should return ServerFailure on error', () async {
      when(() => mockRemoteDataSource.approveUser(tUserId))
          .thenThrow(ServerException.internalError());

      final failure = await repository.approveUser(tUserId);

      expect(failure, isA<ServerFailure>());
    });
  });

  group('rejectUser', () {
    const tUserId = 'user-123';

    test('should return null on success', () async {
      when(() => mockRemoteDataSource.rejectUser(tUserId,
          reason: any(named: 'reason'))).thenAnswer((_) async {});

      final failure =
          await repository.rejectUser(tUserId, reason: 'Invalid info');

      expect(failure, isNull);
      verify(() =>
              mockRemoteDataSource.rejectUser(tUserId, reason: 'Invalid info'))
          .called(1);
    });
  });

  group('getSystemStats', () {
    test('should return SystemStats on success', () async {
      final tStats = SystemStats(
        totalUsers: 100,
        totalStudents: 80,
        totalTeachers: 15,
        totalAdmins: 5,
        pendingApprovals: 12,
        totalSessions: 200,
        completedSessions: 150,
        cancelledSessions: 10,
        averageSessionDuration: 45.0,
        averageGrade: 4.2,
        newUsersThisWeek: 5,
        activeUsersToday: 20,
      );

      when(() => mockRemoteDataSource.getSystemStats())
          .thenAnswer((_) async => tStats);

      final (stats, failure) = await repository.getSystemStats();

      expect(stats, isNotNull);
      expect(stats!.totalUsers, 100);
      expect(failure, isNull);
    });
  });

  group('getSystemSettings', () {
    test('should return SystemSettings on success', () async {
      const tSettings = SystemSettings(
        allowSelfRegistration: true,
        requireApproval: true,
        defaultSessionDuration: 60,
      );

      when(() => mockRemoteDataSource.getSystemSettings())
          .thenAnswer((_) async => tSettings);

      final (settings, failure) = await repository.getSystemSettings();

      expect(settings, isNotNull);
      expect(settings!.requireApproval, true);
      expect(failure, isNull);
    });
  });

  group('updateSystemSettings', () {
    test('should return null on success', () async {
      const tSettings = SystemSettings();

      when(() => mockRemoteDataSource.updateSystemSettings(tSettings))
          .thenAnswer((_) async {});

      final failure = await repository.updateSystemSettings(tSettings);

      expect(failure, isNull);
    });
  });

  group('assignTeacher', () {
    test('should return null on success', () async {
      when(() => mockRemoteDataSource.assignTeacher('student-1', 'teacher-1'))
          .thenAnswer((_) async {});

      final failure = await repository.assignTeacher(
        studentId: 'student-1',
        teacherId: 'teacher-1',
      );

      expect(failure, isNull);
    });
  });
}
