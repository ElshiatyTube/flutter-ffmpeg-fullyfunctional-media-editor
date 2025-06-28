import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../../enums/enums.dart';

@immutable
class CameraState extends Equatable {
  final CameraStatus status;
  final CameraController? cameraCtrl;
  final bool isCameraReady;
  final List<CameraDescription> cameras;
  final CameraPosition currentCameraPosition;
  final XFile? imageFile;
  final XFile? videoFile;
  final bool showTackPictureEffect;
  final bool flashOpenStatus;
  final FlashMode flashMode;
  final File? captureCameraSound;
  final bool? hasSound;
  final String? errorMessage;

  const CameraState({
    this.status = CameraStatus.initial,
    this.cameraCtrl,
    this.isCameraReady = false,
    this.cameras = const [],
    this.currentCameraPosition = CameraPosition.front,
    this.imageFile,
    this.videoFile,
    this.showTackPictureEffect = false,
    this.flashOpenStatus = false,
    this.flashMode = FlashMode.off,
    this.captureCameraSound,
    this.hasSound,
    this.errorMessage,
  });

  bool get isFront => currentCameraPosition == CameraPosition.front;

  CameraState copyWith({
    CameraStatus? status,
    CameraController? cameraCtrl,
    bool? isCameraReady,
    List<CameraDescription>? cameras,
    CameraPosition? currentCameraPosition,
    XFile? imageFile,
    bool? clearImageFile,
    XFile? videoFile,
    bool? clearVideoFile,
    bool? showTackPictureEffect,
    bool? flashOpenStatus,
    FlashMode? flashMode,
    File? captureCameraSound,
    bool? hasSound,
    String? errorMessage,
  }) {
    return CameraState(
      status: status ?? this.status,
      cameraCtrl: cameraCtrl ?? this.cameraCtrl,
      isCameraReady: isCameraReady ?? this.isCameraReady,
      cameras: cameras ?? this.cameras,
      currentCameraPosition:
          currentCameraPosition ?? this.currentCameraPosition,
      imageFile: clearImageFile == true ? null : imageFile ?? this.imageFile,
      videoFile: clearVideoFile == true ? null : videoFile ?? this.videoFile,
      showTackPictureEffect:
          showTackPictureEffect ?? this.showTackPictureEffect,
      flashOpenStatus: flashOpenStatus ?? this.flashOpenStatus,
      flashMode: flashMode ?? this.flashMode,
      captureCameraSound: captureCameraSound ?? this.captureCameraSound,
      hasSound: hasSound ?? this.hasSound,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cameraCtrl,
        isCameraReady,
        cameras,
        currentCameraPosition,
        imageFile,
        videoFile,
        showTackPictureEffect,
        flashOpenStatus,
        flashMode,
        captureCameraSound,
        hasSound,
        errorMessage,
      ];
}

enum CameraStatus {
  initial,
  ready,
  loading,
  imageCaptureSuccess,
  videoRecordInProgress,
  videoRecordSuccess,
  flashChanged,
  previewPaused,
  previewResumed,
  error,
}

