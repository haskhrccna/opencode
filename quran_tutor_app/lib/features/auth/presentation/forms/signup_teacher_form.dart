import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/app_constants.dart';
import 'signup_student_form.dart';
import 'signin_form.dart';

/// Formz input for bio validation (optional)
class Bio extends FormzInput<String, String> {
  const Bio.pure() : super.pure('');
  const Bio.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    // Bio is optional
    if (value.isEmpty) return null;
    
    if (value.length > AppConstants.maxBioLength) {
      return 'validation.bio_max_length';
    }
    return null;
  }
}

/// Formz input for website URL validation (optional)
class WebsiteUrl extends FormzInput<String, String> {
  const WebsiteUrl.pure() : super.pure('');
  const WebsiteUrl.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    // Website is optional
    if (value.isEmpty) return null;
    
    final urlPattern = RegExp(
      r'^(http|https)://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(/\S*)?$',
      caseSensitive: false,
    );
    
    if (!urlPattern.hasMatch(value)) {
      return 'validation.url_invalid';
    }
    return null;
  }
}

/// Formz state for teacher sign up form
class SignUpTeacherFormState extends Equatable with FormzMixin {
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;
  final ArabicName arabicName;
  final EnglishName englishName;
  final PhoneNumber phoneNumber;
  final Bio bio;
  final WebsiteUrl websiteUrl;
  final bool agreeToTerms;

  const SignUpTeacherFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.arabicName = const ArabicName.pure(),
    this.englishName = const EnglishName.pure(),
    this.phoneNumber = const PhoneNumber.pure(),
    this.bio = const Bio.pure(),
    this.websiteUrl = const WebsiteUrl.pure(),
    this.agreeToTerms = false,
  });

  SignUpTeacherFormState copyWith({
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
    ArabicName? arabicName,
    EnglishName? englishName,
    PhoneNumber? phoneNumber,
    Bio? bio,
    WebsiteUrl? websiteUrl,
    bool? agreeToTerms,
  }) {
    return SignUpTeacherFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      arabicName: arabicName ?? this.arabicName,
      englishName: englishName ?? this.englishName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      websiteUrl: websiteUrl ?? this.websiteUrl,
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
        phoneNumber,
        bio,
        websiteUrl,
        agreeToTerms,
      ];

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
        email,
        password,
        confirmPassword,
        arabicName,
        englishName,
        phoneNumber,
        bio,
        websiteUrl,
      ];
}
