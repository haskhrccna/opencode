import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/app_constants.dart';

/// Formz input for email validation
class Email extends FormzInput<String, String> {
  const Email.pure() : super.pure('');
  const Email.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.isEmpty) {
      return 'validation.required';
    }
    if (!AppConstants.emailRegex.hasMatch(value)) {
      return 'validation.email_invalid';
    }
    return null;
  }
}

/// Formz input for password validation
class Password extends FormzInput<String, String> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.isEmpty) {
      return 'validation.required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'validation.password_min_length';
    }
    return null;
  }
}

/// Formz state for sign in form
class SignInFormState extends Equatable with FormzMixin {
  final Email email;
  final Password password;
  final bool rememberMe;

  const SignInFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.rememberMe = false,
  });

  SignInFormState copyWith({
    Email? email,
    Password? password,
    bool? rememberMe,
  }) {
    return SignInFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  @override
  List<Object?> get props => [email, password, rememberMe];

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [email, password];
}
