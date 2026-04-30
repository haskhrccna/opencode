import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_tutor_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:quran_tutor_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:quran_tutor_app/features/admin/presentation/bloc/admin_event.dart';
import 'package:quran_tutor_app/features/admin/presentation/bloc/admin_state.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'الإعدادات',
            onPressed: () => context.go('/admin/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () =>
                context.read<AuthBloc>().add(const SignOutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state.status == AdminStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('خطأ: ${state.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminBloc>().add(const LoadDashboard());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Grid
                if (state.systemStats != null) ...[
                  _buildStatsGrid(state.systemStats!),
                ],
                const SizedBox(height: 24),

                // Admin navigation
                _buildSectionTitle('إدارة'),
                _AdminNavCard(
                  icon: Icons.pending_actions,
                  label: 'الطلاب قيد المراجعة',
                  onTap: () => context.go('/admin/pending'),
                ),
                _AdminNavCard(
                  icon: Icons.person,
                  label: 'إدارة المعلمين',
                  onTap: () => context.go('/admin/teachers'),
                ),
                _AdminNavCard(
                  icon: Icons.event_note,
                  label: 'الجلسات',
                  onTap: () => context.go('/admin/sessions'),
                ),
                _AdminNavCard(
                  icon: Icons.bar_chart,
                  label: 'التقارير',
                  onTap: () => context.go('/admin/reports'),
                ),
                const SizedBox(height: 24),

                // Pending Users Section
                if (state.pendingUsers != null &&
                    state.pendingUsers!.isNotEmpty) ...[
                  _buildSectionTitle('طلبات قيد الانتظار'),
                  _buildPendingUsersList(state.pendingUsers!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(SystemStats stats) {
    final statsList = [
      _StatCard(
        title: 'المستخدمين',
        value: stats.totalUsers.toString(),
        icon: Icons.people,
        color: Colors.blue,
      ),
      _StatCard(
        title: 'الطلاب',
        value: stats.totalStudents.toString(),
        icon: Icons.school,
        color: Colors.green,
      ),
      _StatCard(
        title: 'المعلمين',
        value: stats.totalTeachers.toString(),
        icon: Icons.person,
        color: Colors.orange,
      ),
      _StatCard(
        title: 'قيد الانتظار',
        value: stats.pendingApprovals.toString(),
        icon: Icons.pending_actions,
        color: Colors.red,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: statsList.map(_buildStatCard).toList(),
    );
  }

  Widget _buildStatCard(_StatCard stat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(stat.icon, size: 32, color: stat.color),
            const SizedBox(height: 8),
            Text(
              stat.value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingUsersList(List<AuthUser> users) {
    return Column(
      children: users.map((user) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.displayName?.substring(0, 1) ?? '?'),
            ),
            title: Text(user.displayName ?? 'Unknown'),
            subtitle: Text(user.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    context.read<AdminBloc>().add(ApproveUser(user.id));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    context.read<AdminBloc>().add(RejectUser(userId: user.id));
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard {
  _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _AdminNavCard extends StatelessWidget {
  const _AdminNavCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(label, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
