import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../enums/enums.dart';
import '../../utilities/utils.dart';
import '../cubit/media_editing/media_editing_cubit.dart';


class ColoredFilteredDialog extends StatefulWidget {
  final Function(int)? onTap;
  final Function onChangeOpacity;

  const ColoredFilteredDialog(
      {super.key, required this.onTap, required this.onChangeOpacity});

  @override
  State<ColoredFilteredDialog> createState() => _ColoredFilteredDialogState();
}

class _ColoredFilteredDialogState extends State<ColoredFilteredDialog> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Dialog(
      alignment: const Alignment(0.0, 0.6),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        color: Colors.transparent,
        height: 140,
        child: Column(
          children: [
            SizedBox(
              height: 90.0,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ColorFilterWithName.values.length,
                  itemBuilder: (BuildContext context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        onTap: () => widget.onTap!(index),
                        child: Container(
                          width: width * 0.2,
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                              color: Colors.grey.withOpacity(0.5)),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                if(ColorFilterWithName.values[index] ==
                                    ColorFilterWithName.whiteRadiant){
                                  return const LinearGradient(
                                    colors: [Colors.white, Colors.transparent, Colors.white, Colors.transparent],
                                    stops: [0.1, 0.1, 0.5, 1.2],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomCenter,
                                    transform: GradientRotation(0.5),
                                  ).createShader(bounds);
                                }
                                return LinearGradient(
                                  colors: [
                                    ColorFilterWithName.values[index].orgColor,
                                    Colors.transparent
                                  ],
                                  stops: const [1, 0],
                                ).createShader(bounds);
                              },
                              blendMode:ColorFilterWithName.values[index] ==
                                  ColorFilterWithName.whiteRadiant ?  BlendMode.screen: BlendMode.color,
                              child: Icon(
                                Icons.image_outlined,
                                size: width * .17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            //control color opacity
            BlocBuilder<MediaEditingCubit, MediaEditingState>(
              builder: (BuildContext context, state) {
                printDebug(
                    'colorOpacityIs: ${MediaEditingCubit.get(context).selectedMedia.colorOpacity}');
                var color = MediaEditingCubit.get(context).selectedMedia.color;
                return color.name != 'black' && color.name != 'transparent' && color.name != 'white'
                    ? Slider(
                        value: MediaEditingCubit.get(context)
                            .selectedMedia
                            .colorOpacity,
                        onChanged: (value) {
                          widget.onChangeOpacity(value);
                        },
                        min: 0.0,
                        max: 0.5,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white,
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
