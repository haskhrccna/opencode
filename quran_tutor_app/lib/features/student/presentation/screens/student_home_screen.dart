import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.user == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = state.user!;
        return Scaffold(
          appBar: AppBar(
            title: Text('مرحباً، ${user.arabicName ?? user.displayName ?? ''}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => context.go('/student/profile'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(
                icon: Icons.book_outlined,
                label: 'جلساتي',
                onTap: () => context.go('/student/sessions'),
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                icon: Icons.bar_chart,
                label: 'تقدمي',
                onTap: () => context.go('/student/progress'),
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                icon: Icons.logout,
                label: 'تسجيل الخروج',
                onTap: () => context.read<AuthBloc>().add(const SignOutRequested()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SummaryCard({required this.icon, required this.label, required this.onTap});

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
