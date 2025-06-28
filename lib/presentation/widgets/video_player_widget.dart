import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../utilities/utils.dart';
import '../cubit/video_player/video_player_cubit.dart';


class VideoPlayerWidget extends StatefulWidget {
  final bool isVideoEditingStyle;
  final bool isAd;
  final bool listenVisibility;
  final Function? onVideoPlayBtnTap;

  const VideoPlayerWidget({super.key, required this.isVideoEditingStyle, this.isAd=false,this.listenVisibility=false,this.onVideoPlayBtnTap});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>  with RouteAware, WidgetsBindingObserver{
  late VideoPlayerCubit _cubit;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = VideoPlayerCubit.get(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _cubit.disposeVideo();
    printDebug('disposeVideoWidget');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      printDebug("inactive or paused");
      _cubit.togglePlay(forcePause: true);
    } else if (state == AppLifecycleState.resumed) {
      printDebug("resumed");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(ModalRoute.of(context)!=null){
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    }
  }
  @override
  void didPush() {
    // Route was pushed onto navigator and is now topmost route.
    printDebug('didPush');
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    printDebug('didPopNext');
  }

  @override
  void didPushNext() {
    printDebug('didPushNext');
    _cubit.disposeVideo(emitted: true);
    super.didPushNext();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
      builder: (context, state) {
        final controller = _cubit.controller;
        final videoPosition = _cubit.videoPosition;
        final videoDuration = controller?.value.duration ?? Duration.zero;
        final isInitialized = state.isInitialized && controller != null;
        return GestureDetector(
          onTap:!widget.isVideoEditingStyle? (){
            _cubit.togglePlay();
          }:null,
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: isInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: controller.value.aspectRatio ?? 1.0,
                        child: VideoPlayer(controller),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.only(top:!widget.isAd ? 5.0 : 35.0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if(widget.isVideoEditingStyle)...[
                                GestureDetector(
                                  onTap: (){
                                    _cubit.toggleMute();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(1.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.3),
                                      border: Border.all(color: Colors.white),
                                      shape: BoxShape.circle,
                                    ),
                                    child:Icon(
                                      state.isMuted
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.0,),
                                if(videoPosition!=null)...[
                                  ValueListenableBuilder(
                                    valueListenable: videoPosition,
                                    builder: (BuildContext context, value, Widget? child) {
                                      return Text(
                                        currentVideoSecWithDurationToString(
                                            videoPosition.value.inSeconds,videoDuration.inSeconds),
                                        style: const TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ]
                                else...[
                                  Text(
                                    currentVideoSecToString(videoDuration.inSeconds),
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                                if(widget.isVideoEditingStyle)...[
                                  const SizedBox(width: 5.0,),
                                  GestureDetector(
                                    onTap: (){
                                      _cubit.togglePlay();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(1.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child:Icon(
                                        state.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                    ),
                                  )
                                ]
                              ]
                            ],
                          ),
                        ),
                      ),
                      if (state.delayedPlayPause && !widget.isVideoEditingStyle) ...[
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              icon: Icon(
                                state.isPlaying
                                    ?  Icons.play_arrow
                                    : Icons.pause,
                                color: Colors.white,
                                size: 45,
                              ),
                              onPressed: () {
                                _cubit.togglePlay();
                              },
                            ),
                          ),
                        )
                      ],
                      state.isBuffering
                          ? videoBuffering(context)
                          : Container(),
                      if(widget.isVideoEditingStyle)...[
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height:!widget.isAd ? 15.0 : 10.0,
                            child: VideoProgressIndicator(
                              controller!,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: Colors.white,
                                bufferedColor: Colors.grey,
                                backgroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ]else...[
                        if(videoPosition!=null)...[
                          Container(
                            margin: const EdgeInsets.only(bottom:75),
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: 20.0,
                              width: double.infinity,
                              child: Row(
                                children: [
                                  ValueListenableBuilder(
                                    valueListenable: videoPosition!,
                                    builder: (BuildContext context, value, Widget? child) {
                                      return Text(
                                        formatVideoMinSec(
                                            videoPosition.value.inSeconds),
                                        style: const TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 10.0,),
                                  Expanded(
                                    child: SizedBox(
                                      height: 11.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: VideoProgressIndicator(
                                          controller!,
                                          allowScrubbing: true,
                                          colors: const VideoProgressColors(
                                            playedColor: Colors.white,
                                            bufferedColor: Colors.grey,
                                            backgroundColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.0,),
                                  Text(
                                    formatVideoMinSec(videoDuration.inSeconds),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 10.0,),
                                  GestureDetector(
                                    onTap: (){
                                      _cubit.toggleMute();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(1.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3),
                                        border: Border.all(color: Colors.white),
                                        shape: BoxShape.circle,
                                      ),
                                      child:Icon(
                                        state.isMuted
                                            ? Icons.volume_off
                                            : Icons.volume_up,
                                        color: Colors.white,
                                        size: 15.0,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ]
                      ],
                    ],
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: _cubit.videoThumbnail!=null ? DecorationImage(
                            image:_cubit.videoThumbnail!.contains('http') ? NetworkImage(_cubit.videoThumbnail!) : FileImage(File(_cubit.videoThumbnail!)) as ImageProvider,
                            fit: BoxFit.contain,
                          ) : null,
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: (){
                            if(widget.onVideoPlayBtnTap!=null){
                              widget.onVideoPlayBtnTap?.call();
                            }else{
                              _cubit.initialize();
                            }
                          },
                          child: Container(
                              height: 60,
                              width: 60,
                              decoration:  BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.6),
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
