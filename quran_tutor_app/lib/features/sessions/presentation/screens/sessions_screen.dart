import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/theme/app_colors.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_bloc.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_event.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_state.dart';
import 'package:quran_tutor_app/shared/widgets/session_status_badge.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSessions();
  }

  void _loadSessions() {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    if (user == null) return;

    final bloc = context.read<SessionsBloc>();
    if (user.role == UserRole.student) {
      bloc.add(LoadStudentSessions(user.id));
    } else if (user.role == UserRole.teacher) {
      bloc.add(LoadTeacherSessions(user.id));
    } else {
      bloc.add(const LoadSessions());
    }
  }

  List<Session> _sessionsForDay(List<Session>? sessions, DateTime day) {
    if (sessions == null) return [];
    return sessions.where((s) {
      final local = s.localScheduledAt;
      return local.year == day.year &&
          local.month == day.month &&
          local.day == day.day;
    }).toList();
  }

  Map<DateTime, List<Session>> _groupSessions(List<Session>? sessions) {
    final map = <DateTime, List<Session>>{};
    if (sessions == null) return map;
    for (final session in sessions) {
      final local = session.localScheduledAt;
      final key = DateTime(local.year, local.month, local.day);
      map.putIfAbsent(key, () => []).add(session);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الجلسات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
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
          final sessions = state.sessions ?? [];
          final grouped = _groupSessions(sessions);

          return Column(
            children: [
              TableCalendar<Session>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'شهر',
                  CalendarFormat.twoWeeks: 'أسبوعين',
                  CalendarFormat.week: 'أسبوع',
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onPageChanged: (focused) {
                  _focusedDay = focused;
                },
                eventLoader: (day) =>
                    grouped[DateTime(day.year, day.month, day.day)] ?? [],
                calendarStyle: CalendarStyle(
                  markerDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildSessionsList(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isTeacher = authState.user?.role == UserRole.teacher;
          if (!isTeacher) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _showCreateSessionSheet(context),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildSessionsList(SessionsState state) {
    if (state.status == SessionsStatus.loading && state.sessions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final daySessions =
        _sessionsForDay(state.sessions, _selectedDay ?? DateTime.now());

    if (daySessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.outline),
            SizedBox(height: 16),
            Text('لا توجد جلسات في هذا اليوم'),
          ],
        ),
      );
    }

    final role = context.read<AuthBloc>().state.user?.role;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daySessions.length,
      itemBuilder: (context, index) {
        final session = daySessions[index];
        return _SessionCard(
          session: session,
          onTap: () => context.go(_detailRouteFor(role, session.id)),
        );
      },
    );
  }

  String _detailRouteFor(UserRole? role, String sessionId) {
    switch (role) {
      case UserRole.teacher:
        return '/teacher/sessions/$sessionId';
      case UserRole.admin:
      case UserRole.student:
      case null:
        return '/student/sessions/$sessionId';
    }
  }

  void _showCreateSessionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CreateSessionSheet(),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, this.onTap});

  final Session session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
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
              if (session.notes != null && session.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  session.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: AppColors.outline),
                  const SizedBox(width: 4),
                  Text(
                    session.durationText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (session.isOnline) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.videocam,
                        size: 16, color: AppColors.outline),
                    const SizedBox(width: 4),
                    const Text('عبر الإنترنت', style: TextStyle(fontSize: 12)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateSessionSheet extends StatefulWidget {
  const _CreateSessionSheet();

  @override
  State<_CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends State<_CreateSessionSheet> {
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  int _duration = 60;
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final authState = context.read<AuthBloc>().state;
    final teacherId = authState.user?.id;
    if (teacherId == null) return;

    context.read<SessionsBloc>().add(CreateSession(
          teacherId: teacherId,
          scheduledAt: _scheduledAt.toUtc(),
          durationMinutes: _duration,
          topic: _topicController.text.trim().isEmpty
              ? null
              : _topicController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جلسة جديدة',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _topicController,
            decoration: const InputDecoration(
              labelText: 'الموضوع / السورة',
              prefixIcon: Icon(Icons.menu_book),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('التاريخ والوقت'),
            subtitle: Text(_scheduledAt.toLocal().toString()),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _scheduledAt,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date == null) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_scheduledAt),
              );
              if (time == null) return;
              setState(() {
                _scheduledAt = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.timelapse),
            title: const Text('المدة'),
            subtitle: Text('$_duration دقيقة'),
            trailing: DropdownButton<int>(
              value: _duration,
              items: [30, 45, 60, 90, 120]
                  .map((d) => DropdownMenuItem(value: d, child: Text('$d د')))
                  .toList(),
              onChanged: (v) => setState(() => _duration = v ?? 60),
            ),
          ),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'ملاحظات',
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: const Text('إنشاء الجلسة'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
