import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_bloc.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_event.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  int _duration = 60;
  bool _isOnline = true;

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
          isOnline: _isOnline,
        ));

    Navigator.of(context).pop();
  }

  Future<void> _pickDateTime() async {
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
      _scheduledAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جلسة جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(labelText: 'الموضوع / السورة'),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('التاريخ والوقت'),
              subtitle: Text(_scheduledAt.toLocal().toString()),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('عبر الإنترنت'),
              value: _isOnline,
              onChanged: (v) => setState(() => _isOnline = v),
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
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
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
          ],
        ),
      ),
    );
  }
}
