import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:quran_tutor_app/core/utils/validators/arabic_validators.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, this.teacherInviteCode});
  final String? teacherInviteCode;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arabicNameController = TextEditingController();
  final _englishNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _selectedDob;

  @override
  void dispose() {
    _arabicNameController.dispose();
    _englishNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'إنشاء حساب',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (widget.teacherInviteCode != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'كود المعلم: ${widget.teacherInviteCode}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                TextFormField(
                  controller: _arabicNameController,
                  decoration:
                      const InputDecoration(labelText: 'الاسم بالعربية'),
                  validator: ArabicValidators.validateArabicName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _englishNameController,
                  decoration:
                      const InputDecoration(labelText: 'الاسم بالإنجليزية'),
                  validator: ArabicValidators.validateEnglishName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(labelText: 'البريد الإلكتروني'),
                  keyboardType: TextInputType.emailAddress,
                  validator: ArabicValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                  validator: ArabicValidators.validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الميلاد',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2010),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDob = picked;
                      });
                      _dobController.text =
                          '${picked.day}/${picked.month}/${picked.year}';
                    }
                  },
                  validator: (v) =>
                      _selectedDob == null ? 'يرجى اختيار تاريخ الميلاد' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  obscureText: true,
                  validator: ArabicValidators.validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                  obscureText: true,
                  validator: (v) =>
                      ArabicValidators.validatePasswordConfirmation(
                    v,
                    _passwordController.text,
                  ),
                ),
                const SizedBox(height: 24),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state.status == AuthStatus.error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage ?? 'Error')),
                      );
                    }
                  },
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.status == AuthStatus.loading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate() &&
                                  _selectedDob != null) {
                                context.read<AuthBloc>().add(
                                      SignUpStudentRequested(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                        arabicName:
                                            _arabicNameController.text.trim(),
                                        englishName:
                                            _englishNameController.text.trim(),
                                        dateOfBirth: _selectedDob!,
                                        phoneNumber:
                                            _phoneController.text.trim(),
                                        teacherInviteCode:
                                            widget.teacherInviteCode,
                                      ),
                                    );
                              }
                            },
                      child: state.status == AuthStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('تسجيل'),
                    );
                  },
                ),
                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text('لديك حساب؟ سجل دخولك'),
                ),
                TextButton(
                  onPressed: () => context.go('/auth/teacher-signup'),
                  child: const Text('تسجيل كمعلم بدلاً من ذلك'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
