import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Screen shown to users waiting for admin approval
class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Start periodic refresh to check for approval status updates
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkApprovalStatus(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _checkApprovalStatus() {
    if (!mounted) return;
    context.read<AuthBloc>().add(const RefreshUserRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthState,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top,
                    size: 60,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  l10n.t('pending.title'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Message
                Text(
                  l10n.t('pending.message'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.access_time,
                          title: 'Review Time',
                          subtitle: 'Usually within 24-48 hours',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          title: 'Notification',
                          subtitle: 'You will receive an email when approved',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          icon: Icons.info_outline,
                          title: 'What\'s Next',
                          subtitle: 'You\'ll be able to access your dashboard',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Manual Refresh Button
                OutlinedButton.icon(
                  onPressed: _checkApprovalStatus,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.t('app.refresh')),
                ),
                const SizedBox(height: 16),
                // Logout Button
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const SignOutRequested());
                  },
                  child: Text(l10n.t('pending.logout')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is Authenticated) {
      // User approved! GoRouter redirect will handle navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account has been approved!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else if (state is Rejected) {
      // User rejected
      context.go('/rejected');
    } else if (state is AuthFailureState) {
      // Show error but stay on this screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.userErrorMessage ?? 'Failed to refresh status'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
