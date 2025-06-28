import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

import '../../../enums/enums.dart';
import '../../../utilities/utils.dart';

part 'video_player_state.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  VideoPlayerCubit({
    required this.currentVideo,
    required this.ctx,
    required this.videoType,
    this.isVideoAutoPlay = true,
    this.mediaModel,
    this.videoThumbnail,
    this.isMuteByDefault = false,
    this.isVideoLooping = true,
    this.onVideoFinish,
  }) : super(const VideoPlayerState()) {
    initialize();
  }

  initialize() {
    setInitVideoPosition();
    initVideoPlayer();
    printDebug('videoUrl: $currentVideo controller: ${controller?.hashCode}');
  }

  final String currentVideo;
  final VideoType videoType;
  final String? videoThumbnail;
  final BuildContext ctx;
  final bool isVideoLooping;
  final bool isVideoAutoPlay;
  final dynamic mediaModel;
  final bool isMuteByDefault;
  final Function? onVideoFinish;
  VideoPlayerController? controller;

  static VideoPlayerCubit get(context) =>
      BlocProvider.of<VideoPlayerCubit>(context);

  ValueNotifier? videoPosition;
  
  setInitVideoPosition() {
    videoPosition = ValueNotifier<Duration>(mediaModel?.pausedAt ?? Duration.zero);
    printDebug('pos: ${mediaModel?.pausedAt.toString()}');
  }
  
  Duration get videoDuration => controller?.value.duration ?? Duration.zero;

  Future<void> initVideoPlayer() async {
    if (!isVideoAutoPlay) return;
    
    emit(state.copyWith(status: VideoPlayerStatus.loading));
    
    try {
      // Init video from network url or file
      controller = videoType == VideoType.remote
          ? VideoPlayerController.networkUrl(Uri.parse(currentVideo))
          : VideoPlayerController.file(File(currentVideo));
      
      await controller?.initialize();
      await controller?.setLooping(isVideoLooping);
      
      if (videoPosition?.value == controller!.value.duration) {
        await controller?.seekTo(Duration.zero);
      } else {
        await controller?.seekTo(videoPosition?.value);
      }

      await controller?.play();
      
      if (isMuteByDefault) {
        await controller?.setVolume(0);
      }
      
      controller?.addListener(videoListener);
      
      emit(state.copyWith(
        status: VideoPlayerStatus.playing,
        isInitialized: true,
        isPlaying: true,
        duration: controller?.value.duration ?? Duration.zero,
        volume: controller?.value.volume ?? 1.0,
        isMuted: controller?.value.volume == 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VideoPlayerStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  bool finishChecked = false;
  
  videoListener() {
    if (controller == null) {
      return;
    }
    
    if (controller!.value.isBuffering) {
      if (!state.isBuffering) {
        mediaModel?.isBuffering = true;
        emit(state.copyWith(
          status: VideoPlayerStatus.buffering,
          isBuffering: true,
        ));
      }
    } else {
      if (state.isBuffering) {
        mediaModel?.isBuffering = false;
        if (!controller!.value.isPlaying) {
          controller?.play();
        }
        emit(state.copyWith(
          status: VideoPlayerStatus.playing,
          isBuffering: false,
          isPlaying: controller?.value.isPlaying ?? false,
        ));
      }
    }
    
    videoPosition?.value = controller!.value.position;
    
    // Update position in state
    emit(state.copyWith(
      position: controller?.value.position ?? Duration.zero,
      isPlaying: controller?.value.isPlaying ?? false,
      volume: controller?.value.volume ?? 1.0,
      isMuted: controller?.value.volume == 0,
    ));

    //check if video is finished
    Future.delayed(const Duration(microseconds: 500), () {
      if (controller?.value.position.inSeconds ==
          controller?.value.duration.inSeconds) {
        if (!finishChecked) {
          finishChecked = true;
          onVideoFinish?.call();
        }
      }
    });
  }

  void togglePlay({bool forcePause = false}) {
    if (!state.isInitialized) {
      return;
    }
    
    if (controller!.value.isPlaying || forcePause) {
      emit(state.copyWith(delayedPlayPause: true));
      controller?.pause();
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(delayedPlayPause: false));
      });
    } else {
      emit(state.copyWith(delayedPlayPause: true));
      controller?.play();
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(delayedPlayPause: false));
      });
    }
  }

  disposeVideo({bool emitted = false}) async {
    mediaModel?.pausedAt = videoPosition?.value;
    controller?.removeListener(videoListener);
    await controller?.dispose();
    controller = null;
    videoPosition = null;
    printDebug('disposeVideo');
    
    if (emitted) {
      emit(state.copyWith(status: VideoPlayerStatus.disposed));
    }
  }

  void toggleMute() {
    if (!state.isInitialized) {
      return;
    }
    
    if (controller!.value.volume == 0) {
      controller?.setVolume(1);
    } else {
      controller?.setVolume(0);
    }
    
    emit(state.copyWith(
      volume: controller?.value.volume ?? 1.0,
      isMuted: controller?.value.volume == 0,
    ));
  }

  @override
  Future<void> close() {
    printDebug('disposeVideoCubit');
    return super.close();
  }
  
  @override
  void emit(VideoPlayerState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }
}



