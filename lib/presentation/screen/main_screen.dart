import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/cubit/camera/camera_cubit.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/cubit/sound/sound_cubit.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/screen/media_editing_screen.dart';

import '../../enums/enums.dart';
import '../../utilities/utils.dart';
import '../cubit/camera/camera_state.dart';
import '../cubit/setup/setup_cubit.dart';
import '../cubit/setup/setup_state.dart';
import '../widgets/nav_to_edit_widget.dart';
import '../widgets/options_side_menu.dart';
import '../widgets/record_btn_widget.dart';
import '../widgets/sound_lable_widget.dart';
import '../widgets/speed_widget.dart';
import '../widgets/timer_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late CameraCubit _cameraCubit;
  late SetupCubit _setupCubit;
  late SoundCubit _soundCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraCubit = CameraCubit.get(context);
    _setupCubit = SetupCubit.get(context);
    _soundCubit = SoundCubit.get(context);
    _setupCubit.setScreenContext(context);
    _cameraCubit.initCamera(
        cameraPosition: CameraPosition.front,
        isFirstInit: true,
        context: context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraCubit.state.cameraCtrl == null) {
      return;
    }
    if (!_cameraCubit.state.cameraCtrl!.value.isInitialized) {
      printDebug('camera not initialized');
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cameraCubit.state.cameraCtrl?.dispose();
      printDebug('inactiveCamera');
    } else if (state == AppLifecycleState.resumed) {
      _cameraCubit.initCamera(
          isFirstInit: false,
          cameraPosition: _cameraCubit.state.currentCameraPosition,
          context: context);
      printDebug('resumedCamera');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<CameraCubit, CameraState>(
            builder: (context, state) {
              return state.cameraCtrl != null && state.isCameraReady
                  ? Container(
                      color: Colors.black,
                      child: CameraWidget(
                        controller: state.cameraCtrl!,
                        isEffect: state.showTackPictureEffect,
                      ),
                    )
                  : defaultCircularProgressIndicator();
            },
          ),
          BlocBuilder<SetupCubit, SetupState>(
            builder: (BuildContext context, state) {
              return TimerWidget(
                isRecording: state.isVideoRecording,
                duration: durationToString(state.currentTime.ceil()),
              );
            },
          ),
          const SoundLabelWidget(
            fromCamera: true,
          ),
          BlocBuilder<SetupCubit, SetupState>(
            builder: (BuildContext context, state) {
              return OptionsSideMenu(
                cubit: _setupCubit,
                onFlipCameraTapped: () {
                  if (_setupCubit.state.isVideoRecording) return;
                  _cameraCubit.switchCamera(context);
                },
                onFlashBtnTapped: () {
                  _cameraCubit.manageCameraFlash();
                },
                onSelectMusicTapped: () {
                  if (_setupCubit.state.isVideoRecording) return;
                  _setupCubit.showSoundDialog(context);
                },
                onUploadMediaTapped: () {
                  if (_setupCubit.state.isVideoRecording) return;
                  _setupCubit.pickMediaForPost();
                },
                onSpeedUpTapped: () {
                  if (_setupCubit.state.isVideoRecording) return;
                  _setupCubit.speedHide();
                },
              );
            },
          ),
          BlocBuilder<SetupCubit, SetupState>(
            builder: (BuildContext context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SpeedWidget(),
                  const RecordBtnWidget(),
                ],
              );
            },
          ),
          BlocBuilder<SetupCubit, SetupState>(
            builder: (BuildContext context, state) {
              return state.status != SetupStatus.loadingAddToPostDataList
                  ? Container(
                      alignment: Alignment.bottomRight,
                      margin: const EdgeInsets.only(bottom: 50),
                      child: NavToEditWidget(
                        setupCubit: _setupCubit,
                        onTap: () async {
                          await Future.wait([
                            _cameraCubit.pauseCameraPreview(),
                            _soundCubit.dispose(),
                            _setupCubit.disposeCameraAudioPlayer()
                          ]);
                          WidgetsBinding.instance.removeObserver(this);
                          _setupCubit.navToEditingScreen(context).then((value) {
                            _cameraCubit.resumeCameraPreview();
                            WidgetsBinding.instance.addObserver(this);
                          });
                        },
                      ))
                  : _setupCubit.state.showNextBtn
                      ? Align(
                          alignment: Alignment.center,
                          child: defaultCircularProgressIndicator())
                      : const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }
}

class CameraWidget extends StatelessWidget {
  final CameraController controller;
  final bool isEffect;

  const CameraWidget(
      {super.key, required this.controller, this.isEffect = false});

  @override
  Widget build(BuildContext context) {
    var camera = controller.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Center(
      child: AnimatedOpacity(
          opacity: isEffect ? 0.8 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: CameraPreview(controller)),
    );
  }
}
