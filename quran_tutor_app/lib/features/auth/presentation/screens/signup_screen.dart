import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators/arabic_validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignupScreen extends StatelessWidget {
  final String? teacherInviteCode;

  const SignupScreen({super.key, this.teacherInviteCode});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final arabicNameController = TextEditingController();
    final englishNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final phoneController = TextEditingController();
    final dobController = TextEditingController();
    DateTime? selectedDob;

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
                Text('إنشاء حساب',
                    style: Theme.of(context).textTheme.headlineMedium),
                if (teacherInviteCode != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'كود المعلم: $teacherInviteCode',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                TextFormField(
                  controller: arabicNameController,
                  decoration:
                      const InputDecoration(labelText: 'الاسم بالعربية'),
                  validator: ArabicValidators.validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: englishNameController,
                  decoration:
                      const InputDecoration(labelText: 'الاسم بالإنجليزية'),
                  validator: ArabicValidators.validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration:
                      const InputDecoration(labelText: 'البريد الإلكتروني'),
                  keyboardType: TextInputType.emailAddress,
                  validator: ArabicValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration:
                      const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                  validator: ArabicValidators.validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dobController,
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
                      selectedDob = picked;
                      dobController.text =
                          '${picked.day}/${picked.month}/${picked.year}';
                    }
                  },
                  validator: (v) =>
                      selectedDob == null ? 'يرجى اختيار تاريخ الميلاد' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration:
                      const InputDecoration(labelText: 'كلمة المرور'),
                  obscureText: true,
                  validator: ArabicValidators.validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                  obscureText: true,
                  validator: (v) =>
                      ArabicValidators.validatePasswordConfirmation(
                          v, passwordController.text),
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
                              if (formKey.currentState!.validate() &&
                                  selectedDob != null) {
                                context.read<AuthBloc>().add(
                                      SignUpStudentRequested(
                                        email: emailController.text.trim(),
                                        password: passwordController.text,
                                        arabicName:
                                            arabicNameController.text.trim(),
                                        englishName:
                                            englishNameController.text.trim(),
                                        dateOfBirth: selectedDob!,
                                        phoneNumber:
                                            phoneController.text.trim(),
                                        teacherInviteCode: teacherInviteCode,
                                      ),
                                    );
                              }
                            },
                      child: state.status == AuthStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('تسجيل'),
                    );
                  },
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
