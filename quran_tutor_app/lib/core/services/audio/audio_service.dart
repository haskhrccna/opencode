import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Service for handling audio recording and playback
@singleton
class AudioService {
  final AudioPlayer _player;
  final AudioRecorder _recorder;
  final SupabaseClient _supabase;

  bool _isInitialized = false;
  String? _currentRecordingPath;

  AudioService({
    AudioPlayer? player,
    AudioRecorder? recorder,
    SupabaseClient? supabase,
  })  : _player = player ?? AudioPlayer(),
        _recorder = recorder ?? AudioRecorder(),
        _supabase = supabase ?? Supabase.instance.client;

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Start recording audio
  Future<void> startRecording({String? customPath}) async {
    if (!_isInitialized) await initialize();

    // Check permission
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    // Configure recording
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );

    // Start recording
    _currentRecordingPath = customPath ?? await _generateRecordingPath();
    await _recorder.start(config, path: _currentRecordingPath!);
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    return path;
  }

  /// Check if currently recording
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  /// Play audio from URL
  Future<void> playFromUrl(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  /// Play audio from local file
  Future<void> playFromFile(String filePath) async {
    await _player.setFilePath(filePath);
    await _player.play();
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    await _player.stop();
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Get current position stream
  Stream<Duration> get positionStream => _player.positionStream;

  /// Get duration
  Duration? get duration => _player.duration;

  /// Get playback state
  PlayerState get playbackState => _player.playerState;

  /// Upload recording to Supabase Storage
  Future<String> uploadRecording(String localPath, String sessionId) async {
    final file = File(localPath);
    if (!file.existsSync()) {
      throw Exception('Recording file not found');
    }

    final fileName = 'recordings/$sessionId/${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _supabase.storage
        .from('recordings')
        .upload(fileName, file);

    return _supabase.storage
        .from('recordings')
        .getPublicUrl(fileName);
  }

  /// Delete recording from storage
  Future<void> deleteRecording(String url) async {
    final path = _extractPathFromUrl(url);
    if (path != null) {
      await _supabase.storage.from('recordings').remove([path]);
    }
  }

  /// Generate a unique recording path
  Future<String> _generateRecordingPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  /// Extract storage path from public URL
  String? _extractPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length > 1) {
        return pathSegments.skip(1).join('/');
      }
    } catch (e) {
      // Invalid URL
    }
    return null;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
    await _recorder.dispose();
  }
}
