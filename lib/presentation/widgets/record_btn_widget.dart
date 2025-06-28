import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../enums/enums.dart';
import '../cubit/camera/camera_cubit.dart';
import '../cubit/camera/camera_state.dart';
import '../cubit/setup/setup_cubit.dart';
import '../cubit/setup/setup_state.dart';

class RecordBtnWidget extends StatefulWidget {
  const RecordBtnWidget({super.key});

  @override
  State<RecordBtnWidget> createState() => _RecordBtnWidgetState();
}

class _RecordBtnWidgetState extends State<RecordBtnWidget>
    with TickerProviderStateMixin {
  AnimationController? midController;
  late AnimationController outController;
  late AnimationController strokeController;
  late Animation<double> sizeAnimationForMidCircle;
  late Animation<double> sizeAnimationForOutCircle;
  late Animation<double> rippleAnimationForStroke;
  late Animation<BorderRadius?> radiusAnimation;
  late SetupCubit setupCubit;
  late CameraCubit cameraCubit;
  double strokeValue = 7;
  double midCircleValue = 70;
  double outCircleValue = 1;

  @override
  void initState() {
    setupCubit = SetupCubit.get(context);
    cameraCubit = CameraCubit.get(context);

    midController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    sizeAnimationForMidCircle =
        Tween<double>(begin: 70, end: 50).animate(midController!)
          ..addListener(() {
            midCircleValue = sizeAnimationForMidCircle.value;
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              outController.forward();
            }
          });
    final curvedAnimation =
        CurvedAnimation(parent: midController!, curve: Curves.ease);

    radiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(70),
      end: BorderRadius.circular(8),
    ).animate(curvedAnimation);

    outController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    sizeAnimationForOutCircle =
        Tween<double>(begin: 1, end: 1.7).animate(outController)
          ..addListener(() {
            outCircleValue = sizeAnimationForOutCircle.value;
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              strokeController.forward();
            }
          });

    strokeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    rippleAnimationForStroke =
        Tween<double>(begin: 8, end: 4).animate(strokeController)
          ..addListener(() {
            strokeValue = rippleAnimationForStroke.value;
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              strokeController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              strokeController.forward();
            }
          });
    super.initState();
  }

  @override
  void dispose() {
    midController?.dispose();
    outController.dispose();
    strokeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraCubit, CameraState>(
      listener: (context, state) async {
        if (state.status == CameraStatus.videoRecordInProgress) {
          setupCubit.startTimer();
        }
        if (state.status == CameraStatus.videoRecordSuccess || state.status == CameraStatus.error) {
          setupCubit.stopTimer();
        }
        if (state.status == CameraStatus.videoRecordSuccess) {
          if (setupCubit.currentSound != null) {
            await setupCubit.cameraAudioPlayer?.pause();
            await setupCubit.controlSound(play: false);
          }
          setupCubit.initialMerges(
            isFront: state.isFront,
            mediaType: MediaType.localVideo,
            mediaPath: cameraCubit.state.videoFile!.path,
            isRecorded: true,
          );
        }
        if (state.status == CameraStatus.imageCaptureSuccess) {
          setupCubit.initialMerges(
            isFront: state.isFront,
            mediaType: MediaType.localImage,
            mediaPath: cameraCubit.state.imageFile!.path,
          );
        }
      },
      child: BlocBuilder<SetupCubit, SetupState>(
        builder: (context, state) {
          return Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.only(bottom: 20.0),
            child: GestureDetector(
              onLongPressStart: (longPressDetails) async {
                if (state.medias.isNotEmpty) {
                  return;
                }
                midController?.forward();
                setupCubit.setIsRecordingVideo(true);
                await cameraCubit.startRecordingVideo();
                if (setupCubit.currentSound != null) {
                  setupCubit.controlSound(play: true);
                }
              },
              onTap: () {
                if (state.isVideoRecording) {
                  setupCubit.stopRecorde(context: context, outController: outController, strokeController: strokeController);
                } else {
                  cameraCubit.takePicture();
                }
              },
              child: state.currentTime == 0
                  ? Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white10,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white10,
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white10,
                          ),
                        ),
                      ),
                    )
                  : state.isVideoRecording
                      ? SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Stack(
                                  children: [
                                    midController == null
                                        ? const CircularProgressIndicator()
                                        : Center(
                                            child: AnimatedBuilder(
                                              animation: midController!,
                                              builder: (context, child) => Container(
                                                width: sizeAnimationForMidCircle.value,
                                                height: sizeAnimationForMidCircle.value,
                                                decoration: BoxDecoration(
                                                  color: Colors.red[600],
                                                  borderRadius: radiusAnimation.value,
                                                ),
                                              ),
                                            ),
                                          ),
                                    SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: CircularProgressIndicator(
                                        value: (5 * 100 * 60),
                                        valueColor: const AlwaysStoppedAnimation(Colors.white70),
                                        strokeWidth: strokeValue,
                                        backgroundColor: Colors.pink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: 100,
                          height: 100,
                          child: midController == null
                              ? const CircularProgressIndicator()
                              : SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    value: 0,
                                    strokeWidth: strokeValue,
                                    backgroundColor: (state.medias.isNotEmpty)
                                        ? Colors.grey
                                        : state.currentTime == 0
                                            ? Colors.grey
                                            : Colors.pink,
                                  ),
                                ),
                        ),
            ),
          );
        },
      ),
    );
  }
}
