import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';

class MusicPlaybackData {
  const MusicPlaybackData({
    required this.title,
    required this.artist,
    required this.source,
    this.id = '',
    this.audioUrl = '',
    this.youtubeUrl = '',
    this.spotifyUrl = '',
    this.thumbnailUrl = '',
    this.videoId = '',
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.isPlaying = false,
  });

  final String id;
  final String title;
  final String artist;
  final String source;
  final String audioUrl;
  final String youtubeUrl;
  final String spotifyUrl;
  final String thumbnailUrl;
  final String videoId;
  final Duration duration;
  final Duration position;
  final bool isPlaying;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'source': source,
      'audio_url': audioUrl,
      'youtube_url': youtubeUrl,
      'spotify_url': spotifyUrl,
      'thumbnail_url': thumbnailUrl,
      'video_id': videoId,
      'duration_ms': duration.inMilliseconds,
      'position_ms': position.inMilliseconds,
      'is_playing': isPlaying,
    };
  }

  static MusicPlaybackData fromJson(Map<String, dynamic> json) {
    final youtubeUrl =
        (json['youtube_url'] ?? json['url'] ?? json['video_url'] ?? '')
            .toString();
    final rawVideoId = (json['video_id'] ?? '').toString();
    return MusicPlaybackData(
      id: (json['id'] ?? json['media_id'] ?? rawVideoId).toString(),
      title: (json['title'] ?? 'Nenhuma musica').toString(),
      artist: (json['artist'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      audioUrl:
          (json['audio_url'] ?? json['audioUrl'] ?? json['stream_url'] ?? '')
              .toString(),
      youtubeUrl: youtubeUrl,
      spotifyUrl: (json['spotify_url'] ?? '').toString(),
      thumbnailUrl:
          (json['thumbnail_url'] ??
                  json['thumbnail'] ??
                  json['image_url'] ??
                  '')
              .toString(),
      videoId: rawVideoId.isNotEmpty ? rawVideoId : _videoIdFromUrl(youtubeUrl),
      duration: Duration(
        milliseconds:
            (json['duration_ms'] as num?)?.round() ??
            (json['duration'] is num
                ? ((json['duration'] as num) * 1000).round()
                : 0),
      ),
      position: Duration(
        milliseconds: (json['position_ms'] as num?)?.round() ?? 0,
      ),
      isPlaying: json['is_playing'] == true,
    );
  }

  static String _videoIdFromUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return '';
    final queryId = uri.queryParameters['v'];
    if (queryId != null && queryId.trim().isNotEmpty) return queryId.trim();
    final segments = uri.pathSegments;
    if (uri.host.contains('youtu.be') && segments.isNotEmpty) {
      return segments.first.trim();
    }
    final embedIndex = segments.indexOf('embed');
    if (embedIndex >= 0 && segments.length > embedIndex + 1) {
      return segments[embedIndex + 1].trim();
    }
    return '';
  }
}

class MusicPlaybackResult {
  const MusicPlaybackResult({
    required this.data,
    required this.errorMessage,
    this.payload = const <String, dynamic>{},
  });

  final MusicPlaybackData? data;
  final String errorMessage;
  final Map<String, dynamic> payload;

  bool get success => data != null;

  factory MusicPlaybackResult.success(
    MusicPlaybackData data, [
    Map<String, dynamic> payload = const <String, dynamic>{},
  ]) {
    return MusicPlaybackResult(data: data, errorMessage: '', payload: payload);
  }

  factory MusicPlaybackResult.failure(
    String message, [
    Map<String, dynamic> payload = const <String, dynamic>{},
  ]) {
    return MusicPlaybackResult(
      data: null,
      errorMessage: message.trim().isEmpty
          ? 'Nao encontrei uma musica tocavel para esse pedido.'
          : message.trim(),
      payload: payload,
    );
  }
}

class MusicRepository {
  MusicRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final LocalStorage _storage;
  static const String _localKey = 'music_state';

  Future<MusicPlaybackResult> play(
    String userId,
    String prompt, {
    Map<String, dynamic> musicContext = const <String, dynamic>{},
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/chat',
        body: {
          'message': prompt,
          'locale': 'pt-BR',
          'client_context': {
            'source': 'flutter_app',
            'user_id': userId,
            'intent': 'music_or_chat',
            'music': musicContext,
          },
        },
        auth: false,
      );
      final map = response is Map<String, dynamic>
          ? response
          : <String, dynamic>{};
      final music = map['music'];
      if (music is Map) {
        final data = MusicPlaybackData.fromJson({
          ...music.cast<String, dynamic>(),
          'is_playing': true,
        });
        if (!_isPlayable(data)) {
          return MusicPlaybackResult.failure(
            'O backend respondeu, mas nao enviou um link do YouTube tocavel.',
            map,
          );
        }
        await _storage.saveJson(userId, _localKey, data.toJson());
        return MusicPlaybackResult.success(data, map);
      }

      final fallback = await next(userId, searchQuery: prompt);
      if (fallback.success) return fallback;
      return MusicPlaybackResult.failure(_messageFromPayload(map), map);
    } catch (error) {
      return MusicPlaybackResult.failure(
        'Nao consegui chamar o backend de musica: $error',
      );
    }
  }

  Future<void> stop(String userId) async {
    final local = _storage.getJson(userId, _localKey) ?? <String, dynamic>{};
    await _storage.saveJson(userId, _localKey, {...local, 'is_playing': false});
  }

  Future<MusicPlaybackResult> next(
    String userId, {
    String searchQuery = '',
    String videoId = '',
    String title = '',
    String artist = '',
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/music/next',
        body: {
          'locale': 'pt-BR',
          if (searchQuery.trim().isNotEmpty) 'search_query': searchQuery.trim(),
          if (videoId.trim().isNotEmpty) 'video_id': videoId.trim(),
          if (title.trim().isNotEmpty) 'title': title.trim(),
          if (artist.trim().isNotEmpty) 'artist': artist.trim(),
        },
        auth: false,
      );
      final map = response is Map<String, dynamic>
          ? response
          : <String, dynamic>{};
      final music = map['music'];
      if (music is! Map) {
        return MusicPlaybackResult.failure(_messageFromPayload(map), map);
      }
      final data = MusicPlaybackData.fromJson({
        ...music.cast<String, dynamic>(),
        'is_playing': true,
      });
      if (!_isPlayable(data)) {
        return MusicPlaybackResult.failure(
          'O backend encontrou midia, mas nao enviou um video tocavel.',
          map,
        );
      }
      await _storage.saveJson(userId, _localKey, data.toJson());
      return MusicPlaybackResult.success(data, map);
    } catch (error) {
      return MusicPlaybackResult.failure(
        'Nao consegui buscar a proxima musica: $error',
      );
    }
  }

  MusicPlaybackData? loadLocal(String userId) {
    final local = _storage.getJson(userId, _localKey);
    if (local == null) return null;
    return MusicPlaybackData.fromJson(local);
  }

  Future<String?> spotifyLoginUrl() async {
    try {
      final response = await _apiClient.get('/api/music/status', auth: false);
      if (response is Map<String, dynamic>) {
        final spotify = response['spotify'];
        final url = spotify is Map
            ? (spotify['login_url'] ?? spotify['url'])?.toString()
            : (response['url'] ?? response['login_url'])?.toString();
        if (url == null || url.isEmpty) return null;
        var uri = Uri.parse(url);
        if (uri.scheme == 'http' &&
            (uri.host.contains('ngrok-free.dev') ||
                uri.host.contains('ngrok-free.app'))) {
          uri = uri.replace(scheme: 'https');
        }
        return uri
            .replace(
              queryParameters: {
                ...uri.queryParameters,
                'next': 'auramind://spotify-connected',
              },
            )
            .toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> spotifyAuthenticated() async {
    try {
      final response = await _apiClient.get('/api/music/status', auth: false);
      if (response is! Map<String, dynamic>) return false;
      final spotify = response['spotify'];
      if (spotify is! Map) return false;
      return spotify['authenticated'] == true;
    } catch (_) {
      return false;
    }
  }

  static bool _isPlayable(MusicPlaybackData data) {
    return data.audioUrl.trim().isNotEmpty ||
        data.videoId.trim().isNotEmpty ||
        data.youtubeUrl.trim().isNotEmpty;
  }

  static String actionFromPayload(Map<dynamic, dynamic> payload) {
    final action = (payload['action'] ?? 'play')
        .toString()
        .trim()
        .toLowerCase();
    return const {'play', 'stop', 'next', 'previous'}.contains(action)
        ? action
        : 'play';
  }

  static String _messageFromPayload(Map<String, dynamic> payload) {
    final candidate =
        payload['message'] ?? payload['error'] ?? payload['response'];
    if (candidate is String && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
    return 'O backend respondeu, mas nao retornou uma musica tocavel.';
  }
}
