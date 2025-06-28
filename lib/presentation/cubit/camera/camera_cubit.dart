import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../enums/enums.dart';
import '../../../managers/managers.dart';
import 'camera_state.dart';


class CameraCubit extends Cubit<CameraState> {
  CameraCubit() : super(const CameraState()) {
    _setCameraSound();
  }

  final AudioPlayer cameraAudioPlayer = AudioPlayer();

  static CameraCubit get(context) => BlocProvider.of<CameraCubit>(context);

  Future<void> _setCameraSound() async {
    final captureCameraSound =
        File('${(await getTemporaryDirectory()).path}/music.wav');
    var sound = await rootBundle.load(SoundsManager.cameraEffect);
    await captureCameraSound.writeAsBytes(sound.buffer.asUint8List());
    emit(state.copyWith(captureCameraSound: captureCameraSound));
  }

  Future<void> initCamera({
    required CameraPosition cameraPosition,
    required bool isFirstInit,
    required BuildContext context,
  }) async {
    if (state.cameraCtrl?.value.isPreviewPaused ?? false) {
      return;
    }
    var cameras = state.cameras;
    if (isFirstInit) {
      cameras = await availableCameras();
    }
    final cameraCtrl =
        CameraController(cameras[cameraPosition.id], ResolutionPreset.high);
    await cameraCtrl.initialize();
    await cameraCtrl.lockCaptureOrientation();
    if (!context.mounted) return;

    emit(state.copyWith(
      cameras: cameras,
      currentCameraPosition: cameraPosition,
      cameraCtrl: cameraCtrl,
      isCameraReady: true,
      status: CameraStatus.ready,
    ));
  }

  void switchCamera(BuildContext context) {
    if (state.currentCameraPosition == CameraPosition.front) {
      initCamera(
          cameraPosition: CameraPosition.back,
          isFirstInit: false,
          context: context);
    } else if (state.currentCameraPosition == CameraPosition.back) {
      initCamera(
          cameraPosition: CameraPosition.front,
          isFirstInit: false,
          context: context);
    }
  }

  Future<void> _changeFocusMode(bool isLock) async {
    await state.cameraCtrl
        ?.setFocusMode(isLock ? FocusMode.locked : FocusMode.auto);
    await state.cameraCtrl
        ?.setExposureMode(isLock ? ExposureMode.locked : ExposureMode.auto);
  }

  Future<void> takePicture() async {
    if (state.cameraCtrl == null || !state.cameraCtrl!.value.isInitialized) {
      return;
    }
    if (state.cameraCtrl!.value.isTakingPicture) {
      return;
    }
    try {
      await _changeFocusMode(true);
      emit(state.copyWith(showTackPictureEffect: true));
      List values = await Future.wait([
        if (state.captureCameraSound != null)
          cameraAudioPlayer.play(DeviceFileSource(state.captureCameraSound!.path)),
        if (!state.flashOpenStatus) state.cameraCtrl!.setFlashMode(FlashMode.off),
        state.cameraCtrl!.takePicture()
      ]);
      await _changeFocusMode(false);
      final imageFile = XFile((values.last as XFile).path);
      if (state.flashOpenStatus) manageCameraFlash();
      emit(state.copyWith(
        showTackPictureEffect: false,
        imageFile: imageFile,
        status: CameraStatus.imageCaptureSuccess,
      ));
    } on CameraException catch (e) {
      emit(state.copyWith(
          showTackPictureEffect: false,
          status: CameraStatus.error,
          errorMessage: e.toString()));
    }
  }

  Future<void> startRecordingVideo() async {
    if (state.cameraCtrl == null || !state.cameraCtrl!.value.isInitialized) {
      return;
    }
    if (state.cameraCtrl!.value.isRecordingVideo) {
      return;
    }
    try {
      emit(state.copyWith(status: CameraStatus.videoRecordInProgress));
      await state.cameraCtrl?.startVideoRecording();
    } on CameraException catch (e) {
      emit(state.copyWith(
          status: CameraStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> stopRecordingVideo(bool hasSound) async {
    if (state.cameraCtrl == null || !state.cameraCtrl!.value.isRecordingVideo) {
      return;
    }
    try {
      final file = await state.cameraCtrl?.stopVideoRecording();
      if (file != null) {
        emit(state.copyWith(
          videoFile: file,
          hasSound: hasSound,
          status: CameraStatus.videoRecordSuccess,
        ));
        if (state.flashOpenStatus) manageCameraFlash();
      }
    } on CameraException catch (e) {
      emit(state.copyWith(
          status: CameraStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> manageCameraFlash() async {
    final newFlashStatus = !state.flashOpenStatus;
    try {
      final newFlashMode = newFlashStatus ? FlashMode.torch : FlashMode.off;
      await state.cameraCtrl?.setFlashMode(newFlashMode);
      emit(state.copyWith(
        flashOpenStatus: newFlashStatus,
        flashMode: newFlashMode,
        status: CameraStatus.flashChanged,
      ));
    } on CameraException catch (e) {
      debugPrint("camera error: ${e.toString()}");
      emit(state.copyWith(
          status: CameraStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> pauseCameraPreview() async {
    await state.cameraCtrl?.setFlashMode(FlashMode.off);
    await state.cameraCtrl?.pausePreview();
    emit(state.copyWith(
      flashMode: FlashMode.off,
      status: CameraStatus.previewPaused,
    ));
  }

  Future<void> resumeCameraPreview() async {
    await state.cameraCtrl?.resumePreview();
    emit(state.copyWith(status: CameraStatus.previewResumed));
  }

  @override
  Future<void> close() {
    state.cameraCtrl?.dispose();
    cameraAudioPlayer.dispose();
    return super.close();
  }

  Future<void> disposeCamera() async {
    await state.cameraCtrl?.dispose();
    emit(state.copyWith(isCameraReady: false, cameraCtrl: null));
  }
}
