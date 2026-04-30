import 'package:flutter/material.dart';
import 'package:quran_tutor_app/core/theme/app_colors.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';

/// Extension methods for [SessionStatus] to eliminate duplicated display logic.
extension SessionStatusX on SessionStatus {
  Color get color {
    switch (this) {
      case SessionStatus.scheduled:
        return AppColors.primary;
      case SessionStatus.inProgress:
        return Colors.orange;
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.cancelled:
        return AppColors.error;
      case SessionStatus.rescheduled:
        return Colors.purple;
    }
  }

  String get label {
    switch (this) {
      case SessionStatus.scheduled:
        return 'مجدولة';
      case SessionStatus.inProgress:
        return 'جارية';
      case SessionStatus.completed:
        return 'مكتملة';
      case SessionStatus.cancelled:
        return 'ملغاة';
      case SessionStatus.rescheduled:
        return 'معاد جدولتها';
    }
  }
}

/// Compact status badge widget used across sessions screens.
class SessionStatusBadge extends StatelessWidget {
  const SessionStatusBadge({required this.status, super.key});

  final SessionStatus status;

  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: status.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: status.color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
}
