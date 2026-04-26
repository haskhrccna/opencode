import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators/arabic_validators.dart';
import '../bloc/auth_bloc.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text('إنشاء حساب', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 32),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                  validator: ArabicValidators.validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                  keyboardType: TextInputType.emailAddress,
                  validator: ArabicValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  obscureText: true,
                  validator: ArabicValidators.validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                  obscureText: true,
                  validator: (v) =>
                      ArabicValidators.validatePasswordConfirmation(v, passwordController.text),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(SignInRequested(
                            email: emailController.text.trim(),
                            password: passwordController.text,
                          ));
                    }
                  },
                  child: const Text('تسجيل'),
                ),
                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text('لديك حساب؟ سجل دخولك'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}