import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg_media_editor/models/media_state_data.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/cubit/media_editing/media_editing_cubit.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/cubit/setup/setup_state.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/cubit/sound/sound_cubit.dart';
import 'package:flutter_ffmpeg_media_editor/utilities/ffmpeg_funcs.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

import '../../../enums/enums.dart';
import '../../../flutter_ffmpeg_media_editor.dart';
import '../../../managers/count_down_timer.dart';
import '../../../models/media_model.dart';
import '../../../models/sound_model.dart';
import '../../../utilities/utils.dart';
import '../../screen/media_editing_screen.dart';
import '../../widgets/add_sound_dialog.dart';
import '../camera/camera_cubit.dart';

class SetupCubit extends Cubit<SetupState> {
  SetupCubit({MediaStateData? editPost})
      : super(
          editPost != null
              ? SetupState(
                  initMediaData: editPost,
                  currentTime: 60 - editPost.timeInSec,
                  medias: editPost.medias
                      .map((e) => MediaModel(
                          id: e.id,
                          mediaType: e.mediaType,
                          filePath: e.filePath,
                          videThumbPath: e.videThumbPath,
                          isNew: false,
                          isEdited: false,
                          mediaH: e.mediaH,
                          mediaW: e.mediaW,
                          durationInSeconds: e.durationInSeconds,
                          short: e.short,
                          picked: e.picked))
                      .toList(),
                )
              : const SetupState(),
        );

  static SetupCubit get(context) => BlocProvider.of<SetupCubit>(context);

  late final BuildContext context;

  void setScreenContext(BuildContext context) {
    this.context = context;
  }

  void refresh() {
    emit(state.copyWith(status: SetupStatus.initial));
  }

  // Timer logic
  CountdownTimerController? countdownTimerController;

  void startTimer() {
    final int seconds = state.fixedTime.toInt();
    final int endTime = DateTime.now().millisecondsSinceEpoch + seconds * 1000;
    countdownTimerController = CountdownTimerController(endTime: endTime);
    countdownTimerController?.start();
    countdownTimerController?.addListener(_onCountdownTick);
  }

  void _onCountdownTick() {
    if (state.currentTime == 0) {
      stopTimer();
      emit(state.copyWith(status: SetupStatus.reachOutTime));
    } else {
      videoTiming();
    }
  }

  void stopTimer() {
    countdownTimerController?.dispose();
    countdownTimerController = null;
  }

  void videoTiming() {
    num currentReelsTime = state.currentTime - (1 / state.selectedSpeed.speed);
    currentReelsTime = currentReelsTime < 0 ? 0 : currentReelsTime;
    final newTime = currentReelsTime;
    emit(state.copyWith(currentTime: newTime, status: SetupStatus.timing));
  }

  void stopRecorde({
    required BuildContext context,
    AnimationController? midController,
    required AnimationController outController,
    required AnimationController strokeController,
  }) {
    CameraCubit.get(context).stopRecordingVideo(state.currentSound != null);
    midController?.reverse();
    outController.animateTo(0.0).then((value) {
      outController.stop();
      strokeController.stop();
    });
    emit(state.copyWith(isVideoRecording: false));
  }

  // Video speed logic
  void speed({required VideoSpeedEnum speed}) {
    emit(state.copyWith(
      hideSpeedContainer: !state.hideSpeedContainer,
      selectedSpeed: speed,
      status: SetupStatus.changeSpeed,
    ));
  }

  void speedHide() {
    emit(state.copyWith(
      hideSpeedContainer: !state.hideSpeedContainer,
      status: SetupStatus.changeSpeed,
    ));
  }

  void setCurrentTime(num time) {
    emit(state.copyWith(currentTime: time));
  }


  // Media picking logic
  Future<void> pickMediaForPost() async {
    try {
      FilePickerResult? result = await pickFiles(allowedExtensions: [
        ...allowedVideoExtensions,
        ...allowedImageExtensions
      ]);
      if (result == null) {
        emit(state.copyWith(status: SetupStatus.errorAddToPostDataList));
        return;
      }
      List<MediaModel> updatedMedias = List.from(state.medias);
      await Future.forEach(result.paths, (String? path) async {
        if (path == null) return;
        String renamedPath =
            await renameFilePath(filePath: path, dirName: 'media');
        if (renamedPath.endsWithAny(allowedVideoExtensions)) {
          printDebug('isVideo:$renamedPath');
          await initialMerges(
              mediaPath: renamedPath,
              mediaType: MediaType.localVideo,
              isNew: true,
              isVideoInit: true,
              picked: true,
              updatedMedias: updatedMedias);
        } else if (renamedPath.endsWithAny(allowedImageExtensions)) {
          printDebug('isImage:$renamedPath');
          await initialMerges(
              mediaPath: renamedPath,
              mediaType: MediaType.localImage,
              isNew: true,
              picked: true,
              updatedMedias: updatedMedias);
        }
      });
      emit(state.copyWith(
          medias: updatedMedias, status: SetupStatus.successAddToPostDataList));
    } catch (e) {
      printDebug("error pick image: $e");
      emit(state.copyWith(
          status: SetupStatus.errorAddToPostDataList,
          errorMessage: e.toString()));
    }
  }

  Future<void> setupAndAddToMedias({
    required String filePath,
    required MediaType mediaType,
    bool? isSpeedMerged,
    bool isFront = false,
    bool? isNew,
    bool? isVideoInit,
    bool? isSoundMerged,
    bool? picked,
    required bool isRecorded,
    List<MediaModel>? updatedMedias,
  }) async {
    emit(state.copyWith(status: SetupStatus.loadingAddToPostDataList));
    File? videoThumbnail;
    double? mediaH;
    double? mediaW;
    try {
      bool reduceDuration = false;
      int? durationInSeconds;
      if (mediaType == MediaType.localVideo) {
        if (picked != null && picked) {
          reduceDuration = true;
        } else if (isSoundMerged != null && isSoundMerged && !isRecorded) {
          reduceDuration = true;
        } else {
          reduceDuration = false;
        }
      }
      num newCurrentTime = state.currentTime;
      if (mediaType == MediaType.localVideo) {
        videoThumbnail = await FfmpegFuncs.getVideoThumbnail(filePath);
        if (videoThumbnail == null) return;
        printDebug('thumpPath: ${videoThumbnail.path}');
        List<num> size = await getVideoHeightAndWidthAndDuration(
          url: filePath,
          type: mediaType,
        );
        mediaH = size[0].toDouble();
        mediaW = size[1].toDouble();
        durationInSeconds = size[2].toInt();
        if (reduceDuration) {
          newCurrentTime -= durationInSeconds;
        }
      } else if (mediaType == MediaType.localImage) {
        File image = File(filePath);
        var decodedImage = await decodeImageFromList(image.readAsBytesSync());
        mediaH = decodedImage.height.toDouble();
        mediaW = decodedImage.width.toDouble();
      }
      final newMedia = MediaModel(
        filePath: filePath,
        isFront: isFront,
        id: UniqueKey().hashCode.toString(),
        isSpeedMerged: isSpeedMerged,
        durationInSeconds: durationInSeconds,
        mediaType: mediaType,
        mediaH: mediaH,
        mediaW: mediaW,
        isNew: isNew,
        picked: picked ?? false,
        videThumbPath: videoThumbnail?.path,
        isVideoInit: false,
      );
      final mediasList = updatedMedias ?? List<MediaModel>.from(state.medias);
      mediasList.add(newMedia);
      emit(state.copyWith(
        medias: mediasList,
        currentTime: newCurrentTime,
        status: SetupStatus.successAddToPostDataList,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: SetupStatus.errorAddToPostDataList,
          errorMessage: e.toString()));
      printDebug('ErrorAddToPostDataList: $e');
    }
  }

  SoundModel? get currentSound => state.currentSound;
  AudioPlayer? cameraAudioPlayer;

  Future controlSound({required bool play}) async {
    cameraAudioPlayer = AudioPlayer();
    cameraAudioPlayer!.setReleaseMode(ReleaseMode.loop);
    if (currentSound == null) return;
    if (play) {
      await cameraAudioPlayer!.play(
        UrlSource(currentSound!.url),
      );
      emit(state.copyWith(status: SetupStatus.controlSound));
    } else {
      await cameraAudioPlayer!.dispose();
    }
  }

  removeSound() async {
    cameraAudioPlayer?.dispose();
    cameraAudioPlayer = null;
    // SoundCubit.get(context).removeSound();
    emit(state.copyWith(status: SetupStatus.removeSound));
  }

  Future<void> initialMerges({
    required String mediaPath,
    required MediaType mediaType,
    bool isFront = false,
    bool? isNew,
    bool? isVideoInit,
    bool picked = false,
    bool isRecorded = false,
    List<MediaModel>? updatedMedias,
  }) async {
    emit(state.copyWith(status: SetupStatus.loadingProcessVideo));
    printDebug(
        'audioPath: ${currentSound?.url.toString()} speed: ${state.selectedSpeed.name} isFront $isFront mediaPath: $mediaPath');
    if (currentSound == null &&
        state.selectedSpeed == VideoSpeedEnum.normal &&
        !isFront) {
      await setupAndAddToMedias(
        filePath: mediaPath,
        mediaType: mediaType,
        picked: picked,
        isNew: isNew,
        isVideoInit: isVideoInit,
        isFront: isFront,
        isRecorded: isRecorded,
        updatedMedias: updatedMedias,
      );
    } else {
      showLoadingDialogGif(
          context: context, dismiss: false, text: 'Processing...');
      String finalOutput = mediaPath;
      bool isSpeedMerge = false;
      bool isFrontMerge = false;
      bool isSoundMerged = false;
      if (isFront) {
        String frontOutputPath = await FfmpegFuncs.removeMirrorEffect(
            mediaPath: finalOutput,
            type: mediaType == MediaType.localVideo
                ? FfmpegMediaTypes.video
                : FfmpegMediaTypes.image);
        if (frontOutputPath.isNotEmpty) {
          finalOutput = frontOutputPath;
          isFrontMerge = true;
        }
      }
      if (state.selectedSpeed != VideoSpeedEnum.normal) {
        String speedOutputPath = await FfmpegFuncs.mergeVideoSpeed(
            videoPath: finalOutput, speed: state.selectedSpeed.speed);
        if (speedOutputPath.isNotEmpty) {
          finalOutput = speedOutputPath;
          isSpeedMerge = true;
        }
      }
      if (currentSound != null) {
        String soundOutputPath = await FfmpegFuncs.mergeSoundWithMedia(
            mediaPath: finalOutput,
            audioPath: currentSound!.url,
            type: mediaType == MediaType.localVideo
                ? FfmpegMediaTypes.video
                : FfmpegMediaTypes.image);
        if (soundOutputPath.isNotEmpty) {
          finalOutput = soundOutputPath;
          isSoundMerged = true;
          if (mediaType == MediaType.localImage) {
            mediaType = MediaType.localVideo;
          }
        }
      }
      Navigator.pop(context); // hide loading dialog
      printDebug('outPutIs: $finalOutput');
      await setupAndAddToMedias(
        filePath: finalOutput,
        mediaType: mediaType,
        isSpeedMerged: isSpeedMerge,
        isFront: isFrontMerge,
        isSoundMerged: isSoundMerged,
        picked: picked,
        isRecorded: isRecorded,
        isNew: isNew,
        isVideoInit: isVideoInit,
        updatedMedias: updatedMedias,
      );
    }
  }

  void removeMediaEmitState() {
    emit(state.copyWith(status: SetupStatus.removeMediaEmit));
  }

  void showSoundDialog(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => BlocProvider.value(
          value: SoundCubit.get(context), child: const AddSoundDialog()),
    ))
        .then((value) {
      emit(state.copyWith(status: SetupStatus.initial));
    });
  }

  Future<void> disposeAll() async {
    stopTimer();
    countdownTimerController?.dispose();
    disposeCameraAudioPlayer();
  }

  Future<void> disposeCameraAudioPlayer() async {
    cameraAudioPlayer?.dispose();
    cameraAudioPlayer?.dispose();
  }

  void setIsRecordingVideo(bool bool) {
    emit(state.copyWith(isVideoRecording: bool));
  }

 Future navToEditingScreen(BuildContext context) async {
    if(!context.mounted)return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: this),
        BlocProvider.value(value: SoundCubit.get(context)),
        BlocProvider(create: (_) => MediaEditingCubit(setupCubit: this, soundCubit: SoundCubit.get(context)))
      ],
      child: MediaEditingScreen(),
    )));
  }
}
