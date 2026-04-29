import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:quran_tutor_app/core/utils/validators/arabic_validators.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';

class TeacherSignupScreen extends StatefulWidget {
  const TeacherSignupScreen({super.key});

  @override
  State<TeacherSignupScreen> createState() => _TeacherSignupScreenState();
}

class _TeacherSignupScreenState extends State<TeacherSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arabicNameController = TextEditingController();
  final _englishNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _arabicNameController.dispose();
    _englishNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          SignUpTeacherRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            arabicName: _arabicNameController.text.trim(),
            englishName: _englishNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل معلم')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'حدث خطأ'), backgroundColor: Colors.red),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _arabicNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم بالعربية',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v == null || v.trim().length < 2
                            ? 'الاسم يجب أن يكون حرفين على الأقل'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _englishNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم بالإنجليزية',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v == null || v.trim().length < 2
                            ? 'الاسم يجب أن يكون حرفين على الأقل'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: ArabicValidators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: ArabicValidators.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف (اختياري)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? null
                            : ArabicValidators.validatePhone(v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'نبذة تعريفية (اختياري)',
                      prefixIcon: Icon(Icons.info_outline),
                      alignLabelWithHint: true,
                    ),
                    validator: ArabicValidators.validateBio,
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return FilledButton(
                        onPressed: state.status == AuthStatus.loading ? null : _submit,
                        child: state.status == AuthStatus.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('إنشاء حساب المعلم'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/auth/login'),
                    child: const Text('لديك حساب؟ سجّل الدخول'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
