import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:quran_tutor_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:quran_tutor_app/features/admin/presentation/bloc/admin_event.dart';
import 'package:quran_tutor_app/features/admin/presentation/bloc/admin_state.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late AdminBloc bloc;
  late MockAdminRepository mockRepository;

  setUp(() {
    mockRepository = MockAdminRepository();
    bloc = AdminBloc(mockRepository);
  });

  tearDown(() => bloc.close());

  group('LoadDashboard', () {
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

    final tPendingUsers = [
      AuthUser(
        id: '1',
        email: 'test@example.com',
        role: UserRole.student,
        status: UserStatus.pending,
        createdAt: DateTime.now(),
      ),
    ];

    blocTest<AdminBloc, AdminState>(
      'emits [loading, loaded] when dashboard loads successfully',
      build: () {
        when(() => mockRepository.getSystemStats())
            .thenAnswer((_) async => (tStats, null));
        when(() => mockRepository.getPendingUsers())
            .thenAnswer((_) async => (tPendingUsers, null));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadDashboard()),
      expect: () => [
        isA<AdminState>().having((s) => s.status, 'status', AdminStatus.loading),
        isA<AdminState>()
            .having((s) => s.status, 'status', AdminStatus.loaded)
            .having((s) => s.systemStats, 'systemStats', tStats)
            .having((s) => s.pendingUsers, 'pendingUsers', tPendingUsers),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [loading, error] when stats fails',
      build: () {
        when(() => mockRepository.getSystemStats())
            .thenAnswer((_) async => (null, ServerFailure.internalError()));
        when(() => mockRepository.getPendingUsers())
            .thenAnswer((_) async => (tPendingUsers, null));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadDashboard()),
      expect: () => [
        isA<AdminState>().having((s) => s.status, 'status', AdminStatus.loading),
        isA<AdminState>()
            .having((s) => s.status, 'status', AdminStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', 'Internal server error'),
      ],
    );
  });

  group('ApproveUser', () {
    blocTest<AdminBloc, AdminState>(
      'emits approving then triggers LoadPendingUsers',
      build: () {
        when(() => mockRepository.approveUser('user-1'))
            .thenAnswer((_) async => null);
        when(() => mockRepository.getPendingUsers())
            .thenAnswer((_) async => (<AuthUser>[], null));
        return bloc;
      },
      act: (bloc) => bloc.add(const ApproveUser('user-1')),
      expect: () => [
        isA<AdminState>().having((s) => s.status, 'status', AdminStatus.approving),
        isA<AdminState>().having((s) => s.status, 'status', AdminStatus.loading),
        isA<AdminState>()
            .having((s) => s.status, 'status', AdminStatus.loaded)
            .having((s) => s.pendingUsers, 'pendingUsers', <AuthUser>[]),
      ],
    );
  });

  group('LoadSystemSettings', () {
    const tSettings = SystemSettings(
      allowSelfRegistration: true,
      requireApproval: true,
      defaultSessionDuration: 60,
    );

    blocTest<AdminBloc, AdminState>(
      'emits [loading, loaded] when settings load',
      build: () {
        when(() => mockRepository.getSystemSettings())
            .thenAnswer((_) async => (tSettings, null));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSystemSettings()),
      expect: () => [
        isA<AdminState>().having((s) => s.status, 'status', AdminStatus.loading),
        isA<AdminState>()
            .having((s) => s.status, 'status', AdminStatus.loaded)
            .having((s) => s.systemSettings, 'systemSettings', tSettings),
      ],
    );
  });
}
