import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/theme/app_colors.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_bloc.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_event.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_state.dart';
import 'package:quran_tutor_app/shared/widgets/session_status_badge.dart';

class TeacherSessionsScreen extends StatefulWidget {
  const TeacherSessionsScreen({super.key});

  @override
  State<TeacherSessionsScreen> createState() => _TeacherSessionsScreenState();
}

class _TeacherSessionsScreenState extends State<TeacherSessionsScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      context.read<SessionsBloc>().add(LoadTeacherSessions(user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جلساتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final user = context.read<AuthBloc>().state.user;
              if (user != null) {
                context.read<SessionsBloc>().add(LoadTeacherSessions(user.id));
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<SessionsBloc, SessionsState>(
        listener: (context, state) {
          if (state.status == SessionsStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SessionsStatus.loading &&
              state.sessions == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = state.sessions ?? [];

          if (sessions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 64, color: AppColors.outline),
                  SizedBox(height: 16),
                  Text('لا توجد جلسات مجدولة'),
                ],
              ),
            );
          }

          final upcoming = sessions.where((s) => s.isUpcoming).toList();
          final past = sessions.where((s) => !s.isUpcoming).toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'القادمة'),
                    Tab(text: 'السابقة'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _SessionList(sessions: upcoming, isUpcoming: true),
                      _SessionList(sessions: past, isUpcoming: false),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/teacher/sessions/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.sessions, required this.isUpcoming});

  final List<Session> sessions;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Text(isUpcoming ? 'لا توجد جلسات قادمة' : 'لا توجد جلسات سابقة'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.push('/teacher/sessions/${session.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SessionStatusBadge(status: session.status),
                      const Spacer(),
                      Text(
                        session.formattedLocalTime,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session.topic ?? 'جلسة حفظ القرآن',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer,
                          size: 16, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Text(session.durationText,
                          style: Theme.of(context).textTheme.bodySmall),
                      if (session.studentId != null) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.person,
                            size: 16, color: AppColors.outline),
                        const SizedBox(width: 4),
                        Text('طالب مسند',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                  if (isUpcoming &&
                      session.status == SessionStatus.scheduled) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => showDialog<String>(
                            context: context,
                            builder: (dialogCtx) =>
                                _CancelConfirmDialog(sessionId: session.id),
                          ),
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('إلغاء'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<SessionsBloc>()
                                .add(StartSession(session.id));
                          },
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('بدء'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CancelConfirmDialog extends StatefulWidget {
  const _CancelConfirmDialog({required this.sessionId});
  final String sessionId;

  @override
  State<_CancelConfirmDialog> createState() => _CancelConfirmDialogState();
}

class _CancelConfirmDialogState extends State<_CancelConfirmDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) => AlertDialog(
        title: const Text('إلغاء الجلسة'),
        content: TextField(
          controller: _reasonController,
          decoration:
              const InputDecoration(labelText: 'سبب الإلغاء (اختياري)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SessionsBloc>().add(
                    CancelSession(
                        sessionId: widget.sessionId,
                        reason: _reasonController.text.trim()),
                  );
              Navigator.pop(context);
            },
            child: const Text('إلغاء'),
          ),
        ],
      );
}
