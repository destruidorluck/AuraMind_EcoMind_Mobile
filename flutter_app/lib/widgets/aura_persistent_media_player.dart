import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../core/constants/app_route.dart';
import '../core/theme/aura_colors.dart';
import '../core/theme/aura_radii.dart';
import '../state/aura_controller.dart';

class AuraPersistentMediaControls {
  AuraPersistentMediaControls({
    required this.play,
    required this.pause,
    required this.toggle,
  });

  final Future<void> Function() play;
  final Future<void> Function() pause;
  final Future<void> Function() toggle;
}

class AuraMediaPlayerScope extends InheritedWidget {
  const AuraMediaPlayerScope({
    super.key,
    required this.controls,
    required super.child,
  });

  final AuraPersistentMediaControls controls;

  static AuraPersistentMediaControls? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AuraMediaPlayerScope>()
        ?.controls;
  }

  @override
  bool updateShouldNotify(AuraMediaPlayerScope oldWidget) {
    return controls != oldWidget.controls;
  }
}

class _AuraYoutubePlayerScope extends InheritedWidget {
  const _AuraYoutubePlayerScope({
    required this.youtubeController,
    required super.child,
  });

  final YoutubePlayerController? youtubeController;

  static YoutubePlayerController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AuraYoutubePlayerScope>()
        ?.youtubeController;
  }

  @override
  bool updateShouldNotify(_AuraYoutubePlayerScope oldWidget) =>
      youtubeController != oldWidget.youtubeController;
}

class AuraYoutubePlayerSurface extends StatelessWidget {
  const AuraYoutubePlayerSurface({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _AuraYoutubePlayerScope.maybeOf(context);
    if (controller == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AuraRadii.xl),
      child: YoutubePlayer(controller: controller, aspectRatio: 16 / 9),
    );
  }
}

class AuraPersistentMediaPlayer extends StatefulWidget {
  const AuraPersistentMediaPlayer({
    super.key,
    required this.controller,
    required this.child,
  });

  final AuraController controller;
  final Widget child;

  @override
  State<AuraPersistentMediaPlayer> createState() =>
      _AuraPersistentMediaPlayerState();
}

class _AuraPersistentMediaPlayerState extends State<AuraPersistentMediaPlayer> {
  String _dismissedVideoId = '';
  late final AuraPersistentMediaControls _controls;
  YoutubePlayerController? _youtubeController;
  StreamSubscription<YoutubePlayerValue>? _youtubeSubscription;
  Timer? _youtubeProgressTimer;
  String _loadedYoutubeVideoId = '';
  Duration _lastRequestedYoutubePosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controls = AuraPersistentMediaControls(
      play: _play,
      pause: _pause,
      toggle: _toggle,
    );
  }

  YoutubePlayerController _ensureYoutubeController() {
    final existing = _youtubeController;
    if (existing != null) return existing;
    final controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: false,
        interfaceLanguage: 'pt',
        playsInline: true,
      ),
    );
    _youtubeController = controller;
    _youtubeSubscription = controller.listen(_onYoutubeValue);
    _youtubeProgressTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(_syncYoutubeProgress()),
    );
    return controller;
  }

  @override
  void didUpdateWidget(covariant AuraPersistentMediaPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_syncYoutubeWithMedia());
  }

  @override
  void dispose() {
    _youtubeProgressTimer?.cancel();
    _youtubeSubscription?.cancel();
    _youtubeController?.close();
    super.dispose();
  }

  void _onYoutubeValue(YoutubePlayerValue value) {
    final currentId = widget.controller.currentMedia.videoId.trim();
    if (currentId.isEmpty || currentId != _loadedYoutubeVideoId) return;
    if (value.hasError) {
      widget.controller.syncExternalMusicPlayback(
        playing: false,
        error:
            'O YouTube não conseguiu reproduzir esta música (${value.error.name}).',
      );
      return;
    }
    if (value.playerState == PlayerState.playing &&
        !widget.controller.currentMedia.isPlaying) {
      widget.controller.syncExternalMusicPlayback(playing: true);
    } else if ((value.playerState == PlayerState.paused ||
            value.playerState == PlayerState.ended) &&
        widget.controller.currentMedia.isPlaying) {
      widget.controller.syncExternalMusicPlayback(
        playing: false,
        position: value.playerState == PlayerState.ended
            ? Duration.zero
            : null,
      );
    }
  }

  Future<void> _syncYoutubeProgress() async {
    final media = widget.controller.currentMedia;
    if (_loadedYoutubeVideoId.isEmpty ||
        media.videoId.trim() != _loadedYoutubeVideoId ||
        !media.isPlaying) {
      return;
    }
    try {
      final controller = _youtubeController;
      if (controller == null) return;
      final values = await Future.wait<double>([
        controller.currentTime,
        controller.duration,
      ]);
      _lastRequestedYoutubePosition = Duration(
        milliseconds: (values[0] * 1000).round(),
      );
      widget.controller.syncExternalMusicPlayback(
        playing: true,
        position: _lastRequestedYoutubePosition,
        duration: Duration(milliseconds: (values[1] * 1000).round()),
      );
    } catch (_) {}
  }

  Future<void> _syncYoutubeWithMedia({bool force = false}) async {
    final media = widget.controller.currentMedia;
    final videoId = media.videoId.trim();
    final existingController = _youtubeController;
    if (videoId.isEmpty) {
      if (_loadedYoutubeVideoId.isNotEmpty && existingController != null) {
        await existingController.stopVideo();
        _loadedYoutubeVideoId = '';
      }
      return;
    }
    if (existingController == null &&
        widget.controller.route.mainRoute != AuraRoute.play) {
      return;
    }
    final controller = existingController ?? _ensureYoutubeController();
    final position = media.position;
    if (force || _loadedYoutubeVideoId != videoId) {
      _loadedYoutubeVideoId = videoId;
      _lastRequestedYoutubePosition = position;
      if (media.isPlaying) {
        await controller.loadVideoById(
          videoId: videoId,
          startSeconds: position.inSeconds.toDouble(),
        );
      } else {
        await controller.cueVideoById(
          videoId: videoId,
          startSeconds: position.inSeconds.toDouble(),
        );
      }
      return;
    }
    if ((position - _lastRequestedYoutubePosition).abs() >
        const Duration(seconds: 2)) {
      _lastRequestedYoutubePosition = position;
      await controller.seekTo(
        seconds: position.inMilliseconds / 1000,
        allowSeekAhead: true,
      );
    }
    if (media.isPlaying) {
      await controller.playVideo();
    } else {
      await controller.pauseVideo();
    }
  }

  Future<void> _play() async {
    try {
      if (widget.controller.currentMedia.videoId.trim().isNotEmpty) {
        final controller = _ensureYoutubeController();
        await widget.controller.resumeMusicPlayback();
        await _syncYoutubeWithMedia(force: _loadedYoutubeVideoId.isEmpty);
        await controller.playVideo();
        return;
      }
      await widget.controller.resumeMusicPlayback();
    } catch (error) {
      widget.controller.markMusicPlaybackError(
        'Nao consegui tocar a musica no player: $error',
      );
    }
  }

  Future<void> _pause() async {
    try {
      if (widget.controller.currentMedia.videoId.trim().isNotEmpty) {
        await _youtubeController?.pauseVideo();
      }
      await widget.controller.pauseMusicPlayback();
    } catch (error) {
      widget.controller.markMusicPlaybackError(
        'Nao consegui pausar o player: $error',
      );
    }
  }

  Future<void> _toggle() async {
    if (widget.controller.currentMedia.isPlaying) {
      await _pause();
    } else {
      await _play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.controller.currentMedia;
    final shouldShowMini =
        media.hasAnyMedia &&
        media.isPlaying &&
        (media.id.trim().isNotEmpty ? media.id.trim() : media.title) !=
            _dismissedVideoId;
    final isMobile = MediaQuery.sizeOf(context).width < 720;
    final bottom = isMobile ? 96.0 : 18.0;
    final isMediaRoute = widget.controller.route.mainRoute == AuraRoute.play;
    final isHomeRoute = widget.controller.route.mainRoute == AuraRoute.home;
    if (isMediaRoute && media.videoId.trim().isNotEmpty) {
      _ensureYoutubeController();
    }

    return _AuraYoutubePlayerScope(
      youtubeController: _youtubeController,
      child: AuraMediaPlayerScope(
        controls: _controls,
        child: Stack(
          children: [
            widget.child,
            if (shouldShowMini && !isMediaRoute && !isHomeRoute)
              Positioned(
                left: isMobile ? 12 : null,
                right: 12,
                bottom: bottom,
                width: isMobile ? null : 360,
                child: Dismissible(
                  key: ValueKey(
                    'mini-player-${media.id}-${media.title}-${media.videoId}',
                  ),
                  direction: DismissDirection.horizontal,
                  onDismissed: (_) {
                    setState(
                      () => _dismissedVideoId = media.id.trim().isNotEmpty
                          ? media.id.trim()
                          : media.title,
                    );
                  },
                  child: _MiniMediaPlayer(
                    title: media.title,
                    artist: media.artist,
                    imageUrl: media.imageUrl,
                    videoId: media.videoId,
                    playing: media.isPlaying,
                    prominent: isMediaRoute,
                    onTap: () => widget.controller.go(AuraRoute.play),
                    onToggle: _toggle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniMediaPlayer extends StatelessWidget {
  const _MiniMediaPlayer({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.videoId,
    required this.playing,
    required this.prominent,
    required this.onTap,
    required this.onToggle,
  });

  final String title;
  final String artist;
  final String imageUrl;
  final String videoId;
  final bool playing;
  final bool prominent;
  final VoidCallback onTap;
  final Future<void> Function() onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AuraColors.blue500.withValues(alpha: 0.92),
                AuraColors.purple500.withValues(alpha: 0.88),
              ],
            ),
            borderRadius: BorderRadius.circular(AuraRadii.lg),
            border: Border.all(
              color: AuraColors.cyan400.withValues(alpha: 0.42),
            ),
            boxShadow: [
              BoxShadow(
                color: AuraColors.purple500.withValues(alpha: 0.34),
                blurRadius: prominent ? 34 : 24,
                spreadRadius: prominent ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AuraRadii.md),
                child: SizedBox(
                  width: prominent ? 116 : 92,
                  height: prominent ? 65 : 52,
                  child: _MiniArtwork(imageUrl: imageUrl, videoId: videoId),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tocando',
                      style: TextStyle(
                        color: AuraColors.indigo100,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AuraColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AuraColors.indigo100,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => onToggle(),
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                color: AuraColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniArtwork extends StatelessWidget {
  const _MiniArtwork({required this.imageUrl, required this.videoId});

  final String imageUrl;
  final String videoId;

  @override
  Widget build(BuildContext context) {
    final source = _thumbnailUrl;
    if (source.isEmpty) {
      return Container(
        color: AuraColors.zinc900.withValues(alpha: 0.52),
        alignment: Alignment.center,
        child: const Icon(Icons.music_note_rounded, color: AuraColors.white),
      );
    }
    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AuraColors.zinc900.withValues(alpha: 0.52),
        alignment: Alignment.center,
        child: const Icon(Icons.play_arrow_rounded, color: AuraColors.white),
      ),
    );
  }

  String get _thumbnailUrl {
    final cleanImage = imageUrl.trim();
    if (cleanImage.startsWith('http')) return cleanImage;
    final cleanVideo = videoId.trim();
    if (cleanVideo.isEmpty) return '';
    return 'https://i.ytimg.com/vi/$cleanVideo/hqdefault.jpg';
  }
}
