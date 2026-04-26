import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Screen shown to users whose registration was rejected
class RejectedScreen extends StatelessWidget {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
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
                  color: AppColors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 60,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                l10n.t('rejected.title'),
                style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                l10n.t('rejected.message'),
                style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Contact Card
              Card(
                color: AppColors.errorContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.contact_support_outlined,
                        size: 40,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Need Help?',
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Contact support for more information about your application',
                        style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Open contact support
                        },
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Contact Support'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Try Again Button
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const SignOutRequested());
                  context.go('/auth/signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Create New Account'),
              ),
              const SizedBox(height: 16),
              // Logout Button
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const SignOutRequested());
                },
                child: Text(l10n.t('rejected.logout')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
