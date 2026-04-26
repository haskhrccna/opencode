import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = state.user;
        return Scaffold(
          appBar: AppBar(
            title: Text('مرحباً، ${user.name}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => context.go('/teacher/profile'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _NavCard(
                icon: Icons.event_outlined,
                label: 'الجلسات',
                onTap: () => context.go('/teacher/sessions'),
              ),
              const SizedBox(height: 12),
              _NavCard(
                icon: Icons.people_outline,
                label: 'طلابي',
                onTap: () => context.go('/teacher/students'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(label, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}