import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/theme/app_colors.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_bloc.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_event.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_state.dart';

class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({
    required this.sessionId,
    this.isTeacher = false,
    super.key,
  });

  final String sessionId;
  final bool isTeacher;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SessionsBloc>().add(GetSession(widget.sessionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الجلسة'),
        actions: [
          BlocBuilder<SessionsBloc, SessionsState>(
            builder: (context, state) {
              final session = state.selectedSession;
              if (session == null) return const SizedBox.shrink();

              final authUser = context.read<AuthBloc>().state.user;
              final authRole = authUser?.role;
              final isAdmin = authRole == UserRole.admin;
              final isOwningTeacher = authRole == UserRole.teacher &&
                  authUser != null &&
                  session.teacherId == authUser.id;
              final canManage = isAdmin || isOwningTeacher;

              if (!canManage ||
                  session.status == SessionStatus.completed ||
                  session.status == SessionStatus.cancelled) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                onSelected: (value) => _handleAction(value, session),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  const PopupMenuItem(value: 'cancel', child: Text('إلغاء')),
                  if (session.status == SessionStatus.scheduled)
                    const PopupMenuItem(value: 'start', child: Text('بدء الجلسة')),
                  if (session.status == SessionStatus.inProgress)
                    const PopupMenuItem(value: 'complete', child: Text('إكمال')),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<SessionsBloc, SessionsState>(
        listener: (context, state) {
          if (state.status == SessionsStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SessionsStatus.loading && state.selectedSession == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = state.selectedSession;
          if (session == null) {
            return const Center(child: Text('الجلسة غير موجودة'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBanner(session: session),
                const SizedBox(height: 16),
                _DetailCard(session: session),
                const SizedBox(height: 16),
                if (session.cancellationReason != null)
                  _InfoCard(
                    icon: Icons.cancel,
                    title: 'سبب الإلغاء',
                    value: session.cancellationReason!,
                    color: AppColors.error,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleAction(String action, Session session) {
    final bloc = context.read<SessionsBloc>();
    switch (action) {
      case 'cancel':
        _showCancelDialog(bloc, session.id);
        break;
      case 'start':
        bloc.add(StartSession(session.id));
        break;
      case 'complete':
        bloc.add(CompleteSession(session.id));
        break;
      case 'edit':
        _showEditDialog(session);
        break;
    }
  }

  void _showCancelDialog(SessionsBloc bloc, String sessionId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء الجلسة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'سبب الإلغاء (اختياري)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () {
              bloc.add(CancelSession(sessionId: sessionId, reason: controller.text.trim()));
              Navigator.pop(context);
            },
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Session session) {
    final topicController = TextEditingController(text: session.topic ?? '');
    final notesController = TextEditingController(text: session.notes ?? '');
    var scheduledAt = session.localScheduledAt;
    var duration = session.durationMinutes;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('تعديل الجلسة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: topicController,
                  decoration: const InputDecoration(labelText: 'الموضوع'),
                ),
                ListTile(
                  title: const Text('الوقت'),
                  subtitle: Text(scheduledAt.toString()),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: scheduledAt,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date == null) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(scheduledAt),
                    );
                    if (time == null) return;
                    setState(() {
                      scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                    });
                  },
                ),
                DropdownButtonFormField<int>(
                  value: duration,
                  decoration: const InputDecoration(labelText: 'المدة (دقيقة)'),
                  items: [30, 45, 60, 90, 120]
                      .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                      .toList(),
                  onChanged: (v) => setState(() => duration = v ?? 60),
                ),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SessionsBloc>().add(UpdateSession(
                  sessionId: session.id,
                  scheduledAt: scheduledAt.toUtc(),
                  durationMinutes: duration,
                  topic: topicController.text.trim(),
                  notes: notesController.text.trim(),
                ));
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.session});

  final Session session;

  Color _color(SessionStatus status) {
    switch (status) {
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

  String _text(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return 'مجدولة';
      case SessionStatus.inProgress:
        return 'جارية الآن';
      case SessionStatus.completed:
        return 'مكتملة';
      case SessionStatus.cancelled:
        return 'ملغاة';
      case SessionStatus.rescheduled:
        return 'معاد جدولتها';
    }
  }

  IconData _icon(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return Icons.event;
      case SessionStatus.inProgress:
        return Icons.play_circle;
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.cancelled:
        return Icons.cancel;
      case SessionStatus.rescheduled:
        return Icons.update;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color(session.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color(session.status).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_icon(session.status), color: _color(session.status), size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _text(session.status),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _color(session.status),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                session.formattedLocalTime,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.topic ?? 'جلسة حفظ القرآن',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(session.notes!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const Divider(height: 24),
            _DetailRow(icon: Icons.person, label: 'المعلم', value: session.teacherId),
            if (session.studentId != null)
              _DetailRow(icon: Icons.school, label: 'الطالب', value: session.studentId!),
            _DetailRow(icon: Icons.timelapse, label: 'المدة', value: session.durationText),
            _DetailRow(
              icon: session.isOnline ? Icons.videocam : Icons.location_on,
              label: 'النوع',
              value: session.isOnline ? 'عبر الإنترنت' : 'حضوري',
            ),
            if (session.meetingLink != null)
              _DetailRow(
                icon: Icons.link,
                label: 'رابط الاجتماع',
                value: session.meetingLink!,
                isLink: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLink = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  style: isLink
                      ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          )
                      : Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
