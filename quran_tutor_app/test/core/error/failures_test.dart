import 'package:flutter_test/flutter_test.dart';
import 'package:quran_tutor_app/core/error/failures.dart';

void main() {
  group('Failure equality', () {
    test('two NetworkFailures with same message+code are equal', () {
      const a = NetworkFailure();
      const b = NetworkFailure();
      expect(a, equals(b));
    });

    test('AuthFailure with different messages are not equal', () {
      const a = AuthFailure(message: 'A');
      const b = AuthFailure(message: 'B');
      expect(a, isNot(equals(b)));
    });
  });

  group('NetworkFailure factories', () {
    test('noConnection has correct code', () {
      expect(NetworkFailure.noConnection().code, 'no_connection');
    });

    test('timeout has correct code and message', () {
      final f = NetworkFailure.timeout();
      expect(f.code, 'timeout');
      expect(f.message, 'Connection timed out');
    });
  });

  group('AuthFailure factories', () {
    test('invalidCredentials has correct code', () {
      expect(AuthFailure.invalidCredentials().code, 'invalid_credentials');
    });

    test('sessionExpired has correct code', () {
      expect(AuthFailure.sessionExpired().code, 'session_expired');
    });

    test('emailAlreadyInUse has correct code', () {
      expect(AuthFailure.emailAlreadyInUse().code, 'email_already_in_use');
    });
  });

  group('ServerFailure factories', () {
    test('badRequest has 400', () {
      expect(ServerFailure.badRequest().statusCode, 400);
    });

    test('notFound has 404', () {
      expect(ServerFailure.notFound().statusCode, 404);
    });

    test('internalError has 500', () {
      expect(ServerFailure.internalError().statusCode, 500);
    });
  });

  group('ValidationFailure', () {
    test('requiredField sets fieldErrors', () {
      final f = ValidationFailure.requiredField(fieldName: 'email');
      expect(f.fieldErrors, isNotNull);
      expect(f.fieldErrors!['email'], 'This field is required');
    });
  });

  group('FailureX extension', () {
    test('NetworkFailure is retryable', () {
      expect(const NetworkFailure().isRetryable, isTrue);
    });

    test('ServerFailure is critical and retryable', () {
      final f = ServerFailure.internalError();
      expect(f.isCritical, isTrue);
      expect(f.isRetryable, isTrue);
    });

    test('AuthFailure session_expired is retryable', () {
      expect(AuthFailure.sessionExpired().isRetryable, isTrue);
    });

    test('AuthFailure invalidCredentials is NOT retryable', () {
      expect(AuthFailure.invalidCredentials().isRetryable, isFalse);
    });

    test('userMessage maps NetworkFailure to friendly text', () {
      expect(
        const NetworkFailure().userMessage,
        contains('internet connection'),
      );
    });

    test('userMessage maps ServerFailure to friendly text', () {
      expect(
        ServerFailure.internalError().userMessage.toLowerCase(),
        contains('something went wrong'),
      );
    });
  });
}
