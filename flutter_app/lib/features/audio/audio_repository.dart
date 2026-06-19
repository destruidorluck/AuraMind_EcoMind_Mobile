import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;

import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../services/aura_auth_service.dart';

enum AudioCaptureState {
  idle,
  recording,
  processing,
  uploading,
  completed,
  error,
}

class AudioUploadResult {
  const AudioUploadResult({
    required this.success,
    required this.transcription,
    this.errorMessage = '',
    this.backendResponse = const <String, dynamic>{},
  });

  final bool success;
  final String transcription;
  final String errorMessage;
  final Map<String, dynamic> backendResponse;
}

class AudioRepository {
  AudioRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final LocalStorage _storage;
  AudioRecorder? _recorder;

  AudioRecorder get _audioRecorder => _recorder ??= AudioRecorder();

  SupabaseClient? get _client => AuraAuthService.client;

  static const String _logsKey = 'audio_logs';

  Future<bool> startRecording() async {
    if (kIsWeb) return false;
    final recorder = _audioRecorder;
    final allowed = await recorder.hasPermission();
    if (!allowed) return false;
    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/aura_${DateTime.now().millisecondsSinceEpoch}.wav';
    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
    return true;
  }

  Future<XFile?> stopRecording() async {
    final path = await _audioRecorder.stop();
    if (path == null || path.trim().isEmpty) return null;
    return XFile(path);
  }

  Future<void> cancelRecording() async {
    await _recorder?.cancel();
  }

  Future<AudioUploadResult> uploadAudio({
    required String userId,
    required XFile file,
    required String locale,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) async {
    final bytes = await file.readAsBytes();
    final response = await _apiClient.multipartPost(
      '/api/transcribe',
      fileField: 'audio',
      filename: file.name.isEmpty ? 'audio.wav' : file.name,
      bytes: Uint8List.fromList(bytes),
      fields: {
        'locale': locale,
        'provider': 'auto',
        if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
        if (metadata != null)
          ...metadata.map((key, value) => MapEntry(key, value.toString())),
      },
      auth: false,
    );

    final payload = response is Map<String, dynamic>
        ? response
        : <String, dynamic>{};
    final transcription =
        (payload['transcription'] ??
                payload['text'] ??
                payload['message'] ??
                '')
            .toString();
    final errorMessage = (payload['error'] ?? '').toString();

    await appendAudioLog(
      userId: userId,
      transcription: transcription,
      backendResponse: payload,
    );

    return AudioUploadResult(
      success: transcription.trim().isNotEmpty,
      transcription: transcription,
      errorMessage: errorMessage,
      backendResponse: payload,
    );
  }

  Future<void> appendAudioLog({
    required String userId,
    required String transcription,
    Map<String, dynamic> backendResponse = const <String, dynamic>{},
  }) async {
    final current = _storage.getList(userId, _logsKey);
    current.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': userId,
      'transcription': transcription,
      'created_at': DateTime.now().toIso8601String(),
      'payload': backendResponse,
    });
    if (current.length > 100) {
      current.removeRange(100, current.length);
    }
    await _storage.saveList(userId, _logsKey, current);

    final supabase = _client;
    if (supabase == null) return;
    try {
      await supabase.from('audio_logs').insert({
        'id': current.first['id'],
        'user_id': userId,
        'transcription': transcription,
        'payload': backendResponse,
        'created_at': current.first['created_at'],
      });
    } catch (_) {
      // Local cache keeps the history when Supabase is offline or the table is
      // still waiting for the SQL migration.
    }
  }
}
