import 'package:flutter_test/flutter_test.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/sessions/data/models/session_model.dart';
import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';

void main() {
  final supabaseRow = <String, dynamic>{
    'id': 's-1',
    'teacher_id': 't-1',
    'student_id': 'st-1',
    'scheduled_at': '2026-04-29T10:00:00.000Z',
    'duration_minutes': 60,
    'topic': 'Surah Al-Fatiha',
    'notes': null,
    'status': 'scheduled',
    'created_at': '2026-04-29T09:00:00.000Z',
    'updated_at': null,
    'completed_at': null,
    'recording_url': null,
    'meeting_link': null,
    'location': null,
    'is_online': true,
    'cancellation_reason': null,
    'metadata': null,
  };

  group('SessionModel.fromSupabase', () {
    test('parses fields correctly', () {
      final m = SessionModel.fromSupabase(supabaseRow);
      expect(m.id, 's-1');
      expect(m.teacherId, 't-1');
      expect(m.studentId, 'st-1');
      expect(m.scheduledAt, DateTime.utc(2026, 4, 29, 10));
      expect(m.durationMinutes, 60);
      expect(m.topic, 'Surah Al-Fatiha');
      expect(m.status, 'scheduled');
      expect(m.isOnline, isTrue);
    });

    test('falls back to defaults for missing fields', () {
      final m = SessionModel.fromSupabase({
        'id': 's-2',
        'teacher_id': 't-2',
        'scheduled_at': '2026-04-29T10:00:00.000Z',
        'created_at': '2026-04-29T09:00:00.000Z',
      });
      expect(m.durationMinutes, 60); // default
      expect(m.status, 'scheduled'); // default
      expect(m.isOnline, isTrue); // default
    });
  });

  group('SessionModel.toSupabase', () {
    test('emits ISO-8601 UTC timestamps', () {
      final m = SessionModel.fromSupabase(supabaseRow);
      final out = m.toSupabase();
      expect(out['scheduled_at'], endsWith('Z'));
      expect(out['created_at'], endsWith('Z'));
      expect(out['status'], 'scheduled');
      expect(out['is_online'], true);
    });
  });

  group('SessionModel.toEntity / fromEntity', () {
    test('round-trip preserves core fields', () {
      final m = SessionModel.fromSupabase(supabaseRow);
      final entity = m.toEntity();
      expect(entity.id, m.id);
      expect(entity.teacherId, m.teacherId);
      expect(entity.scheduledAt, m.scheduledAt);
      expect(entity.status, SessionStatus.scheduled);

      final back = SessionModel.fromEntity(entity);
      expect(back.id, m.id);
      expect(back.scheduledAt, m.scheduledAt);
      expect(back.status, m.status);
    });
  });

  group('SessionModel.copyWith', () {
    test('overrides only specified fields', () {
      final m = SessionModel.fromSupabase(supabaseRow);
      final updated = m.copyWith(status: 'completed');
      expect(updated.status, 'completed');
      expect(updated.id, m.id);
      expect(updated.scheduledAt, m.scheduledAt);
    });
  });
}
