import 'package:flutter_test/flutter_test.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';

void main() {
  final created = DateTime.utc(2026, 4, 29);

  AuthUser sample({
    String id = 'u-1',
    String email = 'a@b.co',
    UserRole role = UserRole.student,
    UserStatus status = UserStatus.approved,
  }) {
    return AuthUser(
      id: id,
      email: email,
      role: role,
      status: status,
      createdAt: created,
    );
  }

  group('AuthUser.empty', () {
    test('produces an unauthenticated user', () {
      final empty = AuthUser.empty();
      expect(empty.isAuthenticated, isFalse);
      expect(empty.id, isEmpty);
      expect(empty.email, isEmpty);
    });
  });

  group('isAuthenticated', () {
    test('true when id and email are non-empty', () {
      expect(sample().isAuthenticated, isTrue);
    });

    test('false when id is empty', () {
      expect(sample(id: '').isAuthenticated, isFalse);
    });

    test('false when email is empty', () {
      expect(sample(email: '').isAuthenticated, isFalse);
    });
  });

  group('role helpers', () {
    test('isStudent / isTeacher / isAdmin reflect role', () {
      expect(sample(role: UserRole.student).isStudent, isTrue);
      expect(sample(role: UserRole.teacher).isTeacher, isTrue);
      expect(sample(role: UserRole.admin).isAdmin, isTrue);
    });
  });

  group('status helpers', () {
    test('isPending / isApproved / isRejected / isSuspended', () {
      expect(sample(status: UserStatus.pending).isPending, isTrue);
      expect(sample(status: UserStatus.approved).isApproved, isTrue);
      expect(sample(status: UserStatus.rejected).isRejected, isTrue);
      expect(sample(status: UserStatus.suspended).isSuspended, isTrue);
    });
  });

  group('getRoleLabel / getStatusLabel', () {
    test('returns Arabic label for ar', () {
      final u = sample(role: UserRole.teacher, status: UserStatus.approved);
      expect(u.getRoleLabel('ar'), 'معلم');
      expect(u.getStatusLabel('ar'), 'تم القبول');
    });

    test('returns english value for non-ar', () {
      final u = sample(role: UserRole.teacher, status: UserStatus.approved);
      expect(u.getRoleLabel('en'), 'teacher');
      expect(u.getStatusLabel('en'), 'approved');
    });
  });

  group('copyWith', () {
    test('overrides only specified fields', () {
      final u = sample();
      final updated = u.copyWith(
        status: UserStatus.approved,
        email: 'new@x.io',
      );
      expect(updated.email, 'new@x.io');
      expect(updated.status, UserStatus.approved);
      expect(updated.id, u.id);
      expect(updated.role, u.role);
      expect(updated.createdAt, u.createdAt);
    });
  });

  group('Equatable', () {
    test('two equal AuthUsers compare equal', () {
      expect(sample(), equals(sample()));
    });

    test('different id breaks equality', () {
      expect(sample(id: 'a'), isNot(equals(sample(id: 'b'))));
    });
  });
}
