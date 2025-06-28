import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../enums/enums.dart';
import '../cubit/camera/camera_cubit.dart';
import '../cubit/camera/camera_state.dart';
import '../cubit/setup/setup_cubit.dart';


class OptionsSideMenu extends StatelessWidget {
  final Function()? onFlipCameraTapped;
  final Function()? onFlashBtnTapped;
  final Function()? onUploadMediaTapped;
  final Function()? onSelectMusicTapped;
  final Function()? onSpeedUpTapped;
  final SetupCubit cubit;

  const OptionsSideMenu(
      {super.key,
      // required this.isReel,
      this.onFlashBtnTapped,
      this.onFlipCameraTapped,
      this.onSelectMusicTapped,
      this.onUploadMediaTapped,
      this.onSpeedUpTapped, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 10),
            child: Container(
              margin: const EdgeInsets.only(top: 25.0),
              height: 242,
              width: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black.withOpacity(0.3)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: onFlipCameraTapped,
                      icon: const Icon(
                        CupertinoIcons.arrow_clockwise,
                        color: Colors.white,
                        size: 25.0,
                      )),
                  BlocConsumer<CameraCubit, CameraState>(
                    builder: (context,state){
                      var cameraCubit = CameraCubit.get(context);
                      return IconButton(
                          onPressed: onFlashBtnTapped,
                          icon: Icon(
                            cameraCubit.state.flashOpenStatus
                                ? CupertinoIcons.bolt_fill
                                : CupertinoIcons.bolt_slash_fill,
                            color: Colors.white,
                            size: 25.0,
                          ));
                    },
                    listener: (context, state) {
                    },
                  ),
                  IconButton(
                      onPressed: onSelectMusicTapped,
                      icon: const Icon(
                        CupertinoIcons.music_note_2,
                        color: Colors.white,
                        size: 25.0,
                      )),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                          onPressed: onSpeedUpTapped,
                          icon: const Icon(
                            Icons.speed,
                            color: Colors.white,
                            size: 25.0,
                          )),
                      cubit.state.selectedSpeed!=VideoSpeedEnum.normal ? Text(cubit.state.selectedSpeed.name,style: const TextStyle(color: Colors.white,fontSize: 12),) : const SizedBox.shrink(),
                    ],
                  ),

                  IconButton(
                      onPressed: onUploadMediaTapped,
                      icon: const Icon(
                        CupertinoIcons.photo,
                        color: Colors.white,
                        size: 25.0,
                      ))

                ],
              ),
            ),
          ),
        ));
  }
}
