import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          switch (state.user.role.value) {
            case 'admin':
              context.go('/admin/dashboard');
            case 'teacher':
              context.go('/teacher/home');
            default:
              context.go('/student/home');
          }
        } else if (state is Unauthenticated || state is AuthError) {
          context.go('/auth/login');
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
