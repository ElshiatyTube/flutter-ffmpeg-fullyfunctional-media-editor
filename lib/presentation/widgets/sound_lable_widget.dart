import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/sound_model.dart';
import '../cubit/setup/setup_cubit.dart';
import '../cubit/setup/setup_state.dart';

class SoundLabelWidget extends StatelessWidget {
  final bool fromCamera;
  final SoundModel? sound;

  const SoundLabelWidget({super.key, required this.fromCamera, this.sound});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, state) {
        var cubit = SetupCubit.get(context);
        return fromCamera
            ? cubit.currentSound != null
            ? Positioned(
          top: 60,
          left: 0.0,
          right: 0.0,
          child: Stack(
            children: [
              Positioned(
                bottom: 0.0,
                top: -40.0,
                left: 70,
                child: IconButton(
                  onPressed: () async {
                    SetupCubit.get(context).removeSound();
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 100.0, vertical: 20),
                child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.grey.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            cubit.currentSound!.name ?? " ",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        )
            : Container()
            : sound != null
            ? Positioned(
          top: 50,
          left: 0.0,
          right: 0.0,
          child: Stack(
            children: [
              Positioned(
                bottom: 0.0,
                top: -40.0,
                left: 70,
                child: IconButton(
                  onPressed: () {
                    //    EditPostCubit.get(context).removeMediaSound();
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 100.0, vertical: 20),
                child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.grey.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            sound!.name ?? " ",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        )
            : Container();
      },
    );
  }
}
