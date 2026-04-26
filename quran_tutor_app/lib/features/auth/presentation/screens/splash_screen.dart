import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../bloc/auth_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final role = state.user.role;
          if (role == UserRole.admin) {
            context.go('/admin/dashboard');
          } else if (role == UserRole.teacher) {
            context.go('/teacher/home');
          } else {
            context.go('/student/home');
          }
        } else if (state is Unauthenticated || state is AuthError) {
          context.go('/auth/login');
        }
        // AuthInitial and AuthLoading: remain on splash while spinner shows
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
