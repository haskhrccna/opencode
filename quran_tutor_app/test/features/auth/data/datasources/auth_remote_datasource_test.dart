import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../lib/core/error/exceptions.dart';
import '../../../../lib/features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../../lib/features/auth/data/models/user_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements PostgrestQueryBuilder {}

class MockSupabaseFilterBuilder extends Mock
    implements PostgrestFilterBuilder<Map<String, dynamic>> {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

void main() {
  late AuthRemoteDataSource dataSource;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockSupabaseFilterBuilder mockFilterBuilder;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockSupabaseFilterBuilder();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockSupabase.from(any())).thenReturn(mockQueryBuilder);

    // Chain the query builder calls
    when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
    when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
    when(() => mockFilterBuilder.maybeSingle()).thenAnswer((_) async => null);
    when(() => mockFilterBuilder.single()).thenAnswer((_) async => {});

    dataSource = SupabaseAuthDataSource(supabase: mockSupabase);
  });

  group('getCurrentUser', () {
    test('should return null when no user is logged in', () async {
      // arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // act
      final result = await dataSource.getCurrentUser();

      // assert
      expect(result, isNull);
    });

    test('should return user model when user is logged in and profile exists',
        () async {
      // arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final userData = {
        'id': 'user-123',
        'email': 'test@example.com',
        'role': 'student',
        'status': 'approved',
        'display_name': 'Test User',
        'arabic_name': 'مستخدم تجريبي',
      };
      when(() => mockFilterBuilder.maybeSingle())
          .thenAnswer((_) async => userData);

      // act
      final result = await dataSource.getCurrentUser();

      // assert
      expect(result, isNotNull);
      expect(result!.id, 'user-123');
      expect(result.email, 'test@example.com');
    });
  });

  group('signIn', () {
    const tEmail = 'test@example.com';
    const tPassword = 'Password123';

    test('should return UserModel when sign in is successful', () async {
      // arrange
      final mockUser = MockUser();
      final mockResponse = MockAuthResponse();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn(tEmail);
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockAuth.signInWithPassword(email: tEmail, password: tPassword))
          .thenAnswer((_) async => mockResponse);

      final userData = {
        'id': 'user-123',
        'email': tEmail,
        'role': 'student',
        'status': 'approved',
      };
      when(() => mockFilterBuilder.single()).thenAnswer((_) async => userData);

      // act
      final result = await dataSource.signIn(tEmail, tPassword);

      // assert
      expect(result.id, 'user-123');
      expect(result.email, tEmail);
      verify(() =>
          mockAuth.signInWithPassword(email: tEmail, password: tPassword))
          .called(1);
    });

    test('should throw ServerException when credentials are invalid', () async {
      // arrange
      final mockResponse = MockAuthResponse();
      when(() => mockResponse.user).thenReturn(null);
      when(() => mockAuth.signInWithPassword(email: tEmail, password: tPassword))
          .thenAnswer((_) async => mockResponse);

      // act & assert
      expect(
        () => dataSource.signIn(tEmail, tPassword),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException on network error', () async {
      // arrange
      when(() => mockAuth.signInWithPassword(email: tEmail, password: tPassword))
          .thenThrow(Exception('Network error'));

      // act & assert
      expect(
        () => dataSource.signIn(tEmail, tPassword),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('signUpStudent', () {
    const tEmail = 'newstudent@example.com';
    const tPassword = 'Password123';
    const tArabicName = 'طالب جديد';
    const tEnglishName = 'New Student';
    final tDateOfBirth = DateTime(2000, 1, 1);
    const tPhoneNumber = '+966512345678';

    test('should create user and return UserModel on success', () async {
      // arrange
      final mockUser = MockUser();
      final mockResponse = MockAuthResponse();
      when(() => mockUser.id).thenReturn('new-user-id');
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => mockResponse);

      when(() => mockQueryBuilder.insert(any())).thenAnswer((_) async => []);

      // act
      final result = await dataSource.signUpStudent(
        email: tEmail,
        password: tPassword,
        arabicName: tArabicName,
        englishName: tEnglishName,
        dateOfBirth: tDateOfBirth,
        phoneNumber: tPhoneNumber,
      );

      // assert
      expect(result.email, tEmail);
      expect(result.role, 'student');
      verify(() => mockAuth.signUp(
            email: tEmail,
            password: tPassword,
            data: any(named: 'data'),
          )).called(1);
    });
  });

  group('profile not found', () {
    test('should return basic user when profile is missing', () async {
      // arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockFilterBuilder.maybeSingle()).thenThrow(Exception('Not found'));

      // act
      final result = await dataSource.getCurrentUser();

      // assert
      expect(result, isNotNull);
      expect(result!.id, 'user-123');
    });
  });
}
