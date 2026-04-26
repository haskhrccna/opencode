import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(const SignOutRequested()),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _AdminTile(
            icon: Icons.pending_actions,
            label: 'الطلاب المعلقون',
            onTap: () => context.go('/admin/pending'),
          ),
          _AdminTile(
            icon: Icons.school,
            label: 'المعلمون',
            onTap: () => context.go('/admin/teachers'),
          ),
          _AdminTile(
            icon: Icons.event_note,
            label: 'الجلسات',
            onTap: () => context.go('/admin/sessions'),
          ),
          _AdminTile(
            icon: Icons.bar_chart,
            label: 'التقارير',
            onTap: () => context.go('/admin/reports'),
          ),
          _AdminTile(
            icon: Icons.settings_outlined,
            label: 'الإعدادات',
            onTap: () => context.go('/admin/settings'),
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
