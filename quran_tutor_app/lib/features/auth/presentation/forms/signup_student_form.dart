import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/app_constants.dart';
import 'signin_form.dart';

/// Formz input for Arabic name validation
class ArabicName extends FormzInput<String, String> {
  const ArabicName.pure() : super.pure('');
  const ArabicName.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.isEmpty) {
      return 'validation.name_arabic_required';
    }
    if (value.length < AppConstants.minNameLength) {
      return 'validation.name_arabic_min_length';
    }
    if (value.length > AppConstants.maxNameLength) {
      return 'validation.name_arabic_max_length';
    }
    if (!AppConstants.arabicNameRegex.hasMatch(value)) {
      return 'validation.name_arabic_invalid';
    }
    return null;
  }
}

/// Formz input for English name validation
class EnglishName extends FormzInput<String, String> {
  const EnglishName.pure() : super.pure('');
  const EnglishName.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.isEmpty) {
      return 'validation.name_english_required';
    }
    if (value.length < AppConstants.minNameLength) {
      return 'validation.name_english_min_length';
    }
    if (value.length > AppConstants.maxNameLength) {
      return 'validation.name_english_max_length';
    }
    if (!AppConstants.englishNameRegex.hasMatch(value)) {
      return 'validation.name_english_invalid';
    }
    return null;
  }
}

/// Formz input for phone number validation
class PhoneNumber extends FormzInput<String, String> {
  const PhoneNumber.pure() : super.pure('');
  const PhoneNumber.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.isEmpty) {
      return 'validation.phone_required';
    }
    // Remove spaces and dashes for validation
    final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    if (!AppConstants.phoneRegex.hasMatch(cleanPhone)) {
      return 'validation.phone_invalid';
    }
    return null;
  }
}

/// Formz input for date of birth validation
class DateOfBirth extends FormzInput<DateTime?, String> {
  const DateOfBirth.pure() : super.pure(null);
  const DateOfBirth.dirty([super.value]) : super.dirty();

  @override
  String? validator(DateTime? value) {
    if (value == null) {
      return 'validation.required';
    }
    final age = DateTime.now().difference(value).inDays ~/ 365;
    if (age < AppConstants.minAge) {
      return 'validation.age_min';
    }
    if (age > AppConstants.maxAge) {
      return 'validation.age_max';
    }
    return null;
  }
}

/// Formz input for password confirmation validation
class ConfirmPassword extends FormzInput<String, String> {
  final String originalPassword;
  
  const ConfirmPassword.pure({this.originalPassword = ''}) : super.pure('');
  const ConfirmPassword.dirty({
    required this.originalPassword,
    String value = '',
  }) : super.dirty(value);

  @override
  String? validator(String value) {
    if (value.isEmpty) {
      return 'validation.required';
    }
    if (value != originalPassword) {
      return 'validation.password_mismatch';
    }
    return null;
  }
}

/// Formz input for teacher invite code (optional)
class TeacherInviteCode extends FormzInput<String, String> {
  const TeacherInviteCode.pure() : super.pure('');
  const TeacherInviteCode.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    // Invite code is optional, but if provided must be valid
    if (value.isEmpty) return null;
    
    if (value.length < 6) {
      return 'validation.invite_code_min_length';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'validation.invite_code_invalid';
    }
    return null;
  }
}

/// Formz state for student sign up form
class SignUpStudentFormState extends Equatable with FormzMixin {
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;
  final ArabicName arabicName;
  final EnglishName englishName;
  final DateOfBirth dateOfBirth;
  final PhoneNumber phoneNumber;
  final TeacherInviteCode teacherInviteCode;
  final bool agreeToTerms;

  const SignUpStudentFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.arabicName = const ArabicName.pure(),
    this.englishName = const EnglishName.pure(),
    this.dateOfBirth = const DateOfBirth.pure(),
    this.phoneNumber = const PhoneNumber.pure(),
    this.teacherInviteCode = const TeacherInviteCode.pure(),
    this.agreeToTerms = false,
  });

  SignUpStudentFormState copyWith({
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
    ArabicName? arabicName,
    EnglishName? englishName,
    DateOfBirth? dateOfBirth,
    PhoneNumber? phoneNumber,
    TeacherInviteCode? teacherInviteCode,
    bool? agreeToTerms,
  }) {
    return SignUpStudentFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      arabicName: arabicName ?? this.arabicName,
      englishName: englishName ?? this.englishName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      teacherInviteCode: teacherInviteCode ?? this.teacherInviteCode,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
    );
  }

  /// Check if form is valid and terms are agreed
  bool get isComplete => isValid && agreeToTerms;

  /// Check if passwords match
  bool get passwordsMatch => password.value == confirmPassword.value;

  @override
  List<Object?> get props => [
        email,
        password,
        confirmPassword,
        arabicName,
        englishName,
        dateOfBirth,
        phoneNumber,
        teacherInviteCode,
        agreeToTerms,
      ];

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
        email,
        password,
        confirmPassword,
        arabicName,
        englishName,
        dateOfBirth,
        phoneNumber,
        teacherInviteCode,
      ];
}
