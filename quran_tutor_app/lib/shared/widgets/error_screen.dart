import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/core/localization/app_localizations.dart';

/// Error screen that displays different UI based on Failure type
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    this.failure,
    this.onRetry,
    this.customMessage,
  });
  final Failure? failure;
  final VoidCallback? onRetry;
  final String? customMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.maybeOf(context);
    final errorData = _getErrorData(context, l10n);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Icon(
                errorData.icon,
                size: 100,
                color: errorData.iconColor,
              ),
              const SizedBox(height: 24),

              // Error Title
              Text(
                errorData.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error Message
              Text(
                customMessage ?? failure?.userMessage ?? errorData.message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),

              // Technical details (only in debug mode)
              if (_showTechnicalDetails && failure?.message != null)
                _buildTechnicalDetails(context, l10n),

              const SizedBox(height: 32),

              // Retry Button
              if (onRetry != null && (failure?.isRetryable ?? false))
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n?.t('error.retry') ?? 'Retry'),
                  ),
                ),

              const SizedBox(height: 16),

              // Go Home Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/auth/login'),
                  child: Text(l10n?.t('error.go_home') ?? 'Go Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalDetails(BuildContext context, AppLocalizations? l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (l10n?.isArabic ?? false) ? 'تفاصيل تقنية:' : 'Technical Details:',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            failure!.message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
          if (failure?.code != null) ...[
            const SizedBox(height: 4),
            Text(
              'Code: ${failure!.code}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get error data based on failure type
  _ErrorData _getErrorData(BuildContext context, AppLocalizations? l10n) {
    if (failure == null) {
      return _ErrorData.unknown(l10n);
    }

    final colorScheme = Theme.of(context).colorScheme;

    if (failure is NetworkFailure) {
      return _ErrorData(
        icon: Icons.wifi_off,
        iconColor: Colors.orange,
        title: l10n?.t('error.network') ?? 'Network Error',
        message: failure!.message,
      );
    }

    if (failure is AuthFailure) {
      return _ErrorData(
        icon: Icons.lock_outline,
        iconColor: colorScheme.primary,
        title: l10n?.t('error.auth') ?? 'Authentication Error',
        message: failure!.message,
      );
    }

    if (failure is ServerFailure) {
      return _ErrorData(
        icon: Icons.cloud_off,
        iconColor: Colors.red,
        title: l10n?.t('error.server') ?? 'Server Error',
        message: failure!.message,
      );
    }

    if (failure is CacheFailure) {
      return _ErrorData(
        icon: Icons.storage_outlined,
        iconColor: Colors.amber,
        title: l10n?.t('error.cache') ?? 'Cache Error',
        message: failure!.message,
      );
    }

    if (failure is ValidationFailure) {
      return _ErrorData(
        icon: Icons.error_outline,
        iconColor: Colors.orange,
        title: l10n?.t('error.validation') ?? 'Validation Error',
        message: failure!.message,
      );
    }

    return _ErrorData.unknown(l10n);
  }

  /// Whether to show technical details (only in debug mode — never leak
  /// raw server/exception messages to end users in release builds).
  bool get _showTechnicalDetails => kDebugMode;
}

/// Error data holder
class _ErrorData {
  _ErrorData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });

  factory _ErrorData.unknown(AppLocalizations? l10n) => _ErrorData(
        icon: Icons.error_outline,
        iconColor: Colors.grey,
        title: l10n?.t('error.title') ?? 'Error',
        message: l10n?.t('error.unknown') ?? 'Something went wrong',
      );
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
}
