import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../models/aura_models.dart';

class AuraMusicPlayerSnapshot {
  const AuraMusicPlayerSnapshot({
    required this.playing,
    required this.position,
    required this.duration,
  });

  final bool playing;
  final Duration position;
  final Duration duration;
}

class AuraMusicPlayerService {
  AuraMusicPlayerService();

  AudioPlayer? _player;
  final StreamController<AuraMusicPlayerSnapshot> _snapshots =
      StreamController<AuraMusicPlayerSnapshot>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  String _loadedUrl = '';

  Stream<AuraMusicPlayerSnapshot> get snapshots => _snapshots.stream;

  AudioPlayer _ensurePlayer() {
    final existing = _player;
    if (existing != null) return existing;

    final player = AudioPlayer();
    _player = player;
    player.setReleaseMode(ReleaseMode.stop);
    _subscriptions
      ..add(
        player.onPositionChanged.listen((position) {
          _position = position;
          _emit();
        }),
      )
      ..add(
        player.onDurationChanged.listen((duration) {
          _duration = duration;
          _emit();
        }),
      )
      ..add(
        player.onPlayerStateChanged.listen((state) {
          _playing = state == PlayerState.playing;
          _emit();
        }),
      )
      ..add(
        player.onPlayerComplete.listen((_) {
          _playing = false;
          _position = Duration.zero;
          _emit();
        }),
      );
    return player;
  }

  Future<void> play(AuraMedia media) async {
    final url = media.audioUrl.trim();
    if (url.isEmpty) {
      throw StateError('audio_url_missing');
    }
    final player = _ensurePlayer();
    if (_loadedUrl != url) {
      _loadedUrl = url;
      _position = Duration.zero;
      await player.stop();
      await player.play(UrlSource(url));
    } else {
      await player.resume();
    }
    _playing = true;
    _emit();
  }

  Future<void> pause() async {
    await _player?.pause();
    _playing = false;
    _emit();
  }

  Future<void> stop() async {
    await _player?.stop();
    _playing = false;
    _position = Duration.zero;
    _emit();
  }

  Future<void> seek(Duration position) async {
    final clamped = _duration == Duration.zero
        ? position
        : Duration(
            milliseconds: position.inMilliseconds
                .clamp(0, _duration.inMilliseconds)
                .toInt(),
          );
    await _player?.seek(clamped);
    _position = clamped;
    _emit();
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _player?.dispose();
    _player = null;
    await _snapshots.close();
  }

  void _emit() {
    if (_snapshots.isClosed) return;
    _snapshots.add(
      AuraMusicPlayerSnapshot(
        playing: _playing,
        position: _position,
        duration: _duration,
      ),
    );
  }
}
