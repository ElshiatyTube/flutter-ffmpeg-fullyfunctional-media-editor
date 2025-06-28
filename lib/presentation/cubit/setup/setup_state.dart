import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ffmpeg_media_editor/models/media_state_data.dart';
import '../../../enums/enums.dart';
import '../../../models/media_model.dart';
import '../../../models/sound_model.dart';


enum SetupStatus {
  initial,
  loading,
  success,
  error,
  timing,
  controlSound,
  removeSound,
  changeSpeed,
  mediaTypeChanged,
  reachOutTime,
  stopRecordPostTime,
  showNextBtn,
  loadingAddToPostDataList,
  successAddToPostDataList,
  errorAddToPostDataList,
  loadingProcessVideo,
  successProcessVideo,
  errorProcessVideo,
  removeMediaEmit,
}

@immutable
class SetupState extends Equatable {
  final SetupStatus status;
  final MediaStateData? initMediaData;
  final List<MediaModel> medias;
  final bool isInVideoPage;
  final bool isVideoRecording;
  final num currentTime;
  final int fixedTime;
  final bool hideSpeedContainer;
  final VideoSpeedEnum selectedSpeed;
  final String? errorMessage;
  final SoundModel? currentSound;

  const SetupState({
    this.status = SetupStatus.initial,
    this.initMediaData,
    this.medias = const [],
    this.isInVideoPage = true,
    this.isVideoRecording = false,
    this.currentTime = 60,
    this.fixedTime = 60,
    this.hideSpeedContainer = true,
    this.selectedSpeed = VideoSpeedEnum.normal,
    this.errorMessage,
    this.currentSound,
  });

  bool get showNextBtn => medias.isNotEmpty;

  SetupState copyWith({
    SetupStatus? status,
    MediaStateData? initMediaData,
    List<MediaModel>? medias,
    bool? isInVideoPage,
    bool? isVideoRecording,
    num? currentTime,
    int? fixedTime,
    int? fixedPostTime,
    bool? hideSpeedContainer,
    VideoSpeedEnum? selectedSpeed,
    String? errorMessage,
    SoundModel? currentSound,
  }) {
    return SetupState(
      status: status ?? this.status,
      initMediaData: initMediaData ?? this.initMediaData,
      medias: medias ?? this.medias,
      isInVideoPage: isInVideoPage ?? this.isInVideoPage,
      isVideoRecording: isVideoRecording ?? this.isVideoRecording,
      currentTime: currentTime ?? this.currentTime,
      fixedTime: fixedTime ?? this.fixedTime,
      hideSpeedContainer: hideSpeedContainer ?? this.hideSpeedContainer,
      selectedSpeed: selectedSpeed ?? this.selectedSpeed,
      errorMessage: errorMessage ?? this.errorMessage,
      currentSound: currentSound ?? this.currentSound,
    );
  }

  @override
  List<Object?> get props => [
    status,
    initMediaData,
    medias,
    isInVideoPage,
    isVideoRecording,
    currentTime,
    fixedTime,
    hideSpeedContainer,
    selectedSpeed,
    errorMessage,
    currentSound,
  ];
}