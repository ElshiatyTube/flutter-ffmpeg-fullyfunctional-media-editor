part of 'video_player_cubit.dart';

enum VideoPlayerStatus {
  initial,
  loading,
  playing,
  paused,
  buffering,
  disposed,
  error,
}

@immutable
class VideoPlayerState extends Equatable {
  final VideoPlayerStatus status;
  final bool isInitialized;
  final bool isPlaying;
  final bool isBuffering;
  final bool isMuted;
  final bool delayedPlayPause;
  final Duration position;
  final Duration duration;
  final double volume;
  final String? errorMessage;

  const VideoPlayerState({
    this.status = VideoPlayerStatus.initial,
    this.isInitialized = false,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isMuted = false,
    this.delayedPlayPause = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.errorMessage,
  });

  VideoPlayerState copyWith({
    VideoPlayerStatus? status,
    bool? isInitialized,
    bool? isPlaying,
    bool? isBuffering,
    bool? isMuted,
    bool? delayedPlayPause,
    Duration? position,
    Duration? duration,
    double? volume,
    String? errorMessage,
  }) {
    return VideoPlayerState(
      status: status ?? this.status,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isMuted: isMuted ?? this.isMuted,
      delayedPlayPause: delayedPlayPause ?? this.delayedPlayPause,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isInitialized,
        isPlaying,
        isBuffering,
        isMuted,
        delayedPlayPause,
        position,
        duration,
        volume,
        errorMessage,
      ];
}