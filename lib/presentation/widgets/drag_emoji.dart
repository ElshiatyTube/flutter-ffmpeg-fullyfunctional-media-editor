import 'package:flutter/material.dart';

import '../../models/media_model.dart';
import 'image_emoji.dart';


class DragEmoji extends StatelessWidget {
  final EmojiInfo selectedEmoji;
  final bool isPressed;
  final BuildContext myContext;
  final Function onDragEnd;
  final Function onPress;
  final Function removeItem;
  const DragEmoji({super.key,required this.selectedEmoji,required this.myContext, required this.onDragEnd, required this.onPress, required this.removeItem, required this.isPressed});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: selectedEmoji.x,
      top: selectedEmoji.y,
      child: GestureDetector(
        onTap: isPressed? (){
          removeItem(selectedEmoji);
        } :(){
          onPress(selectedEmoji);

        },
        child: Draggable(
          feedback: ImageEmoji(emoji:selectedEmoji,isEmoji: true,isLongPressed: isPressed,),
          child: ImageEmoji(emoji:selectedEmoji,isEmoji: true,isLongPressed: isPressed,),
          onDragEnd: (drag) {
            onDragEnd(selectedEmoji,drag);
          },
        ),
      ),
    );
  }
}

