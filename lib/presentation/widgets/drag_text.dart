import 'package:flutter/material.dart';

import '../../models/media_model.dart';
import 'image_text.dart';



class DragText extends StatelessWidget {
  final TextInfo currentText;
  final Function onDragEnd;
  final Function onLongPress;
  final Function onTapToEdit;
  final Function removeText;

  const DragText(
      {super.key, required this.currentText,required this.onDragEnd, required this.onLongPress, required this.onTapToEdit, required this.removeText});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: currentText.x,
      top: currentText.y,
      child: GestureDetector(
        onLongPress: () {
          onLongPress(currentText);
        },
        onTap: () {
          if(currentText.isLongPressed){
            removeText(currentText);
          }else{
            onTapToEdit(currentText);
          }
        },
        child: Draggable(
          feedback: ImageText(textInfo: currentText),
          child: ImageText(textInfo: currentText),
          onDragEnd: (drag) {
            onDragEnd(currentText,drag);
          },
        ),
      ),
    );
  }

}

