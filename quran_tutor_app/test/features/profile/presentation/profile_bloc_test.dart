import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';
import 'package:quran_tutor_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:quran_tutor_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quran_tutor_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:quran_tutor_app/features/profile/presentation/bloc/profile_state.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late ProfileBloc bloc;
  late MockProfileRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      UserProfile(
        id: '',
        email: '',
        role: UserRole.student,
        status: UserStatus.approved,
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockRepository = MockProfileRepository();
    bloc = ProfileBloc(mockRepository);
  });

  tearDown(() => bloc.close());

  final tProfile = UserProfile(
    id: 'user-1',
    email: 'test@example.com',
    role: UserRole.student,
    status: UserStatus.approved,
    createdAt: DateTime.now(),
    displayName: 'Test User',
    arabicName: 'مستخدم تجريبي',
    phoneNumber: '0501234567',
  );

  group('LoadProfile', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [loading, loaded] when profile loads successfully',
      build: () {
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => (tProfile, null));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProfile()),
      expect: () => [
        isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loading),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loaded)
            .having((s) => s.profile?.id, 'profile.id', 'user-1'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [loading, error] when profile fails to load',
      build: () {
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => (null, ServerFailure.internalError()));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProfile()),
      expect: () => [
        isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loading),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', 'Internal server error'),
      ],
    );
  });

  group('UpdateProfile', () {
    final updatedProfile = tProfile.copyWith(displayName: 'Updated Name');

    blocTest<ProfileBloc, ProfileState>(
      'emits [updating, loaded] when update succeeds',
      build: () {
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => (tProfile, null));
        when(() => mockRepository.updateProfile(any()))
            .thenAnswer((_) async => (updatedProfile, null));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const LoadProfile());
        await bloc.stream.firstWhere((s) => s.status == ProfileStatus.loaded);
        bloc.add(const UpdateProfile(englishName: 'Updated Name'));
      },
      skip: 2,
      expect: () => [
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating)
            .having((s) => s.profile?.displayName, 'profile.displayName', 'Test User'),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loaded)
            .having((s) => s.profile?.displayName, 'profile.displayName', 'Updated Name'),
      ],
    );
  });

  group('LoadTeachers', () {
    final tTeacher = UserProfile(
      id: 'teacher-1',
      email: 'teacher@example.com',
      role: UserRole.teacher,
      status: UserStatus.approved,
      createdAt: DateTime.now(),
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [loading, loaded] with teachers list',
      build: () {
        when(() => mockRepository.getTeachers())
            .thenAnswer((_) async => ([tTeacher], null));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadTeachers()),
      expect: () => [
        isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loading),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loaded)
            .having((s) => s.teachers?.length, 'teachers.length', 1)
            .having((s) => s.teachers?.first.role, 'teachers.first.role', UserRole.teacher),
      ],
    );
  });

  group('LoadStudentsByTeacher', () {
    final tStudent = UserProfile(
      id: 'student-1',
      email: 'student@example.com',
      role: UserRole.student,
      status: UserStatus.approved,
      createdAt: DateTime.now(),
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [loading, loaded] with students list',
      build: () {
        when(() => mockRepository.getStudentsByTeacher('teacher-1'))
            .thenAnswer((_) async => ([tStudent], null));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadStudentsByTeacher('teacher-1')),
      expect: () => [
        isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loading),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loaded)
            .having((s) => s.students?.length, 'students.length', 1)
            .having((s) => s.students?.first.role, 'students.first.role', UserRole.student),
      ],
    );
  });

  group('DeleteAvatar', () {
    blocTest<ProfileBloc, ProfileState>(
      'reloads profile after avatar deletion',
      build: () {
        when(() => mockRepository.deleteAvatar())
            .thenAnswer((_) async => null);
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => (tProfile, null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteAvatar()),
      expect: () => [
        isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.updating),
        isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loading),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loaded)
            .having((s) => s.profile?.id, 'profile.id', 'user-1'),
      ],
    );
  });
}
