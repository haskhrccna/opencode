import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Signup screen with role selection (student/teacher)
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _studentFormKey = GlobalKey<FormBuilderState>();
  final _teacherFormKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('auth.signup.title')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.school),
              text: l10n.isArabic ? 'طالب' : 'Student',
            ),
            Tab(
              icon: const Icon(Icons.person),
              text: l10n.isArabic ? 'معلم' : 'Teacher',
            ),
          ],
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthState,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStudentForm(l10n, theme),
            _buildTeacherForm(l10n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentForm(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: FormBuilder(
        key: _studentFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Arabic Name
            FormBuilderTextField(
              name: 'arabicName',
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.name_label') + ' (Arabic)',
                hintText: 'أدخل اسمك بالعربية',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: l10n.t('validation.name_arabic_required'),
                ),
                FormBuilderValidators.minLength(
                  AppConstants.minNameLength,
                  errorText: l10n.t('validation.name_arabic_min_length'),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // English Name
            FormBuilderTextField(
              name: 'englishName',
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.name_label') + ' (English)',
                hintText: 'Enter your name in English',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: l10n.t('validation.name_english_required'),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Email
            FormBuilderTextField(
              name: 'email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.email_label'),
                hintText: l10n.t('auth.signup.email_hint'),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: l10n.t('validation.required'),
                ),
                FormBuilderValidators.email(
                  errorText: l10n.t('validation.email_invalid'),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Phone Number
            FormBuilderTextField(
              name: 'phoneNumber',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.phone_label'),
                hintText: '05XXXXXXXX',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: l10n.t('validation.phone_required'),
                ),
                FormBuilderValidators.match(
                  r'^(\+966|0)5[0-9]{8}$',
                  errorText: l10n.t('validation.phone_invalid'),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Date of Birth
            FormBuilderDateTimePicker(
              name: 'dateOfBirth',
              inputType: InputType.date,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.dob_label'),
                hintText: 'DD/MM/YYYY',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              validator: FormBuilderValidators.required(
                errorText: l10n.t('validation.required'),
              ),
              format: DateFormat('dd/MM/yyyy'),
            ),
            const SizedBox(height: 16),
            // Password
            FormBuilderTextField(
              name: 'password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.password_label'),
                hintText: l10n.t('auth.signup.password_hint'),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: l10n.t('validation.required'),
                ),
                FormBuilderValidators.minLength(
                  AppConstants.minPasswordLength,
                  errorText: l10n.t('validation.password_min_length'),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Confirm Password
            FormBuilderTextField(
              name: 'confirmPassword',
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.confirm_password_label'),
                hintText: l10n.t('auth.signup.confirm_password_hint'),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: l10n.t('validation.required'),
                ),
                (val) {
                  if (val != _studentFormKey.currentState?.fields['password']?.value) {
                    return l10n.t('validation.password_mismatch');
                  }
                  return null;
                },
              ]),
            ),
            const SizedBox(height: 16),
            // Teacher Invite Code (Optional)
            FormBuilderTextField(
              name: 'teacherInviteCode',
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.invite_code_label'),
                hintText: l10n.t('auth.signup.invite_code_hint'),
                prefixIcon: const Icon(Icons.card_giftcard_outlined),
              ),
            ),
            const SizedBox(height: 16),
            // Terms Checkbox
            _buildTermsCheckbox(l10n),
            const SizedBox(height: 24),
            // Submit Button
            _buildSubmitButton(l10n, true),
            const SizedBox(height: 16),
            // Login Link
            _buildLoginLink(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherForm(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: FormBuilder(
        key: _teacherFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Arabic Name
            FormBuilderTextField(
              name: 'arabicName',
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.name_label') + ' (Arabic)',
                hintText: 'أدخل اسمك بالعربية',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: FormBuilderValidators.required(
                errorText: l10n.t('validation.name_arabic_required'),
              ),
            ),
            const SizedBox(height: 16),
            // English Name
            FormBuilderTextField(
              name: 'englishName',
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.name_label') + ' (English)',
                hintText: 'Enter your name in English',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: FormBuilderValidators.required(
                errorText: l10n.t('validation.name_english_required'),
              ),
            ),
            const SizedBox(height: 16),
            // Email
            FormBuilderTextField(
              name: 'email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.email_label'),
                hintText: l10n.t('auth.signup.email_hint'),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: l10n.t('validation.required'),
                ),
                FormBuilderValidators.email(
                  errorText: l10n.t('validation.email_invalid'),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Phone Number
            FormBuilderTextField(
              name: 'phoneNumber',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.phone_label'),
                hintText: '05XXXXXXXX',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: l10n.t('validation.phone_required'),
                ),
                FormBuilderValidators.match(
                  r'^(\+966|0)5[0-9]{8}$',
                  errorText: l10n.t('validation.phone_invalid'),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Bio (Optional)
            FormBuilderTextField(
              name: 'bio',
              maxLines: 3,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.bio_label'),
                hintText: l10n.t('auth.signup.bio_hint'),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),
            // Website (Optional)
            FormBuilderTextField(
              name: 'websiteUrl',
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.website_label'),
                hintText: 'https://example.com',
                prefixIcon: const Icon(Icons.link_outlined),
              ),
            ),
            const SizedBox(height: 16),
            // Password
            FormBuilderTextField(
              name: 'password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.password_label'),
                hintText: l10n.t('auth.signup.password_hint'),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: l10n.t('validation.required'),
                ),
                FormBuilderValidators.minLength(
                  AppConstants.minPasswordLength,
                  errorText: l10n.t('validation.password_min_length'),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Confirm Password
            FormBuilderTextField(
              name: 'confirmPassword',
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.t('auth.signup.confirm_password_label'),
                hintText: l10n.t('auth.signup.confirm_password_hint'),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: l10n.t('validation.required'),
                ),
                (val) {
                  if (val != _teacherFormKey.currentState?.fields['password']?.value) {
                    return l10n.t('validation.password_mismatch');
                  }
                  return null;
                },
              ]),
            ),
            const SizedBox(height: 16),
            // Terms Checkbox
            _buildTermsCheckbox(l10n),
            const SizedBox(height: 24),
            // Submit Button
            _buildSubmitButton(l10n, false),
            const SizedBox(height: 16),
            // Login Link
            _buildLoginLink(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox(AppLocalizations l10n) {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: Text(
            'I agree to the Terms of Service and Privacy Policy',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n, bool isStudent) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.isLoading || !_agreeToTerms
              ? null
              : () => _submit(isStudent),
          child: state.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.t('auth.signup.submit')),
        );
      },
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.t('auth.signup.have_account')),
        TextButton(
          onPressed: () => context.go('/auth/login'),
          child: Text(l10n.t('auth.signup.login')),
        ),
      ],
    );
  }

  void _submit(bool isStudent) {
    final formKey = isStudent ? _studentFormKey : _teacherFormKey;

    if (!(formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final values = formKey.currentState!.value;

    if (isStudent) {
      context.read<AuthBloc>().add(
            SignUpStudentRequested(
              email: values['email'] as String,
              password: values['password'] as String,
              arabicName: values['arabicName'] as String,
              englishName: values['englishName'] as String,
              dateOfBirth: values['dateOfBirth'] as DateTime,
              phoneNumber: values['phoneNumber'] as String,
              teacherInviteCode: values['teacherInviteCode'] as String?,
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            SignUpTeacherRequested(
              email: values['email'] as String,
              password: values['password'] as String,
              arabicName: values['arabicName'] as String,
              englishName: values['englishName'] as String,
              phoneNumber: values['phoneNumber'] as String,
              bio: values['bio'] as String?,
              websiteUrl: values['websiteUrl'] as String?,
            ),
          );
    }
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthFailureState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.userErrorMessage ?? 'Sign up failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
