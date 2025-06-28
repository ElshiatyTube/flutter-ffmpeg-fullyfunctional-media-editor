import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/media_model.dart';
import '../../utilities/utils.dart';
import '../cubit/media_editing/media_editing_cubit.dart';
import 'add_text_dialog.dart';
import 'colored_filtered_dialog.dart';


class VideoEditingSideMenu extends StatelessWidget {
  final Function(int)? selectColoredFilter;
  final Function()? addText;
  final Function(EmojiModel emoji)? selectEmoji;
  final Function()? saveToGallery;
  final TextEditingController textController;
  final Function onChangeOpacity;
  final Function? pickImageAndOverlay;
  final Function? cropImage;
  final Function?rotateImage;

  final bool isVideo;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const VideoEditingSideMenu(
      {Key? key,
      required this.selectColoredFilter,
      required this.selectEmoji,
      required this.addText,
      required this.textController,
        this.pickImageAndOverlay,
        this.rotateImage,
      required this.saveToGallery, required this.onChangeOpacity, required this.isVideo, required this.scaffoldKey, this.cropImage,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height * .30,
        margin: const EdgeInsets.only(top: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if(selectColoredFilter!=null)...[
              SideMenuItem(
                icon: Icon(Icons.color_lens_outlined, color: Colors.black26,),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return BlocProvider.value(
                          value: MediaEditingCubit.get(context),
                          child: ColoredFilteredDialog(
                            onTap:(color)=> selectColoredFilter!(color), onChangeOpacity: (double value) {
                            onChangeOpacity(value);
                          },
                          ),
                        );
                      });
                },
              ),
              const SizedBox(height: 3),
            ],

            if(selectEmoji!=null)SideMenuItem(
              icon: Icon(Icons.emoji_emotions_outlined, color: Colors.black26,),
              onTap: () {
                //TODO: Show selectable emojis view
              },
            ),

            if(pickImageAndOverlay!=null)...[
              const SizedBox(height: 3),
              SideMenuItem(
                icon: Icon(Icons.image_outlined, color: Colors.white,),
                onTap: () {
                  pickImageAndOverlay?.call();
                },
              ),
            ],

            if(!isVideo)...[
              const SizedBox(height: 3),
              SideMenuItem(
                icon: Icon(Icons.crop_outlined, color: Colors.white,),
                onTap: () {
                  cropImage?.call();
                },
              ),
            ],
            const SizedBox(height: 3),
            SideMenuItem(
              icon: Icon(Icons.rotate_right_outlined, color: Colors.black26,),
              onTap: () {
                rotateImage?.call();
              },
            ),
            if(addText!=null)...[
              const SizedBox(height: 3),

              SideMenuItem(
                icon: Icon(Icons.text_fields_outlined, color: Colors.black26,),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AddTextDialog(
                          textEditingController:textController ,
                          onTap: addText,
                        );
                      });
                },
              ),
            ],

            const SizedBox(height: 3),
            SideMenuItem(
              icon: Icon(Icons.download_outlined, color: Colors.black26,),
              onTap: saveToGallery,
            ),
          ],
        ),
      ),
    );
  }
}

class SideMenuItem extends StatelessWidget {
  final Widget icon;
  final Function()? onTap;

  const SideMenuItem({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipOval(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              width: 25.0,
              height: 25.0,
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
