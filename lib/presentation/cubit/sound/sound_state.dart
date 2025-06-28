import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';

import '../../../models/sound_model.dart';

enum SoundStatus {
  initial,
  loading,
  playing,
  paused,
  stopped,
  error,
  selected,
  removed,
}

class SoundState extends Equatable {
  final SoundStatus status;
  final AudioPlayer? audioPlayer;
  final bool isPlaying;
  final SoundModel? soundPlaying;
  final SoundModel? selectedSound;
  final String? errorMessage;
  final bool? isLocal;
  final List<SoundModel> sounds;

  const SoundState({
    this.status = SoundStatus.initial,
    this.audioPlayer,
    this.isPlaying = false,
    this.soundPlaying,
    this.selectedSound,
    this.errorMessage,
    this.isLocal,
    this.sounds = const [],
  });

  SoundState copyWith({
    SoundStatus? status,
    AudioPlayer? audioPlayer,
    bool? isPlaying,
    SoundModel? soundPlaying,
    SoundModel? selectedSound,
    String? errorMessage,
    bool? isLocal,
    List<SoundModel>? sounds,
  }) {
    return SoundState(
      status: status ?? this.status,
      audioPlayer: audioPlayer ?? this.audioPlayer,
      isPlaying: isPlaying ?? this.isPlaying,
      soundPlaying: soundPlaying ?? this.soundPlaying,
      selectedSound: selectedSound ?? this.selectedSound,
      errorMessage: errorMessage ?? this.errorMessage,
      isLocal: isLocal ?? this.isLocal,
      sounds: sounds ?? this.sounds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    audioPlayer,
    isPlaying,
    soundPlaying,
    selectedSound,
    errorMessage,
    isLocal,
    sounds,
  ];
}