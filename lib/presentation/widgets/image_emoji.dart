import 'dart:io';


import 'package:flutter/material.dart';

import '../../enums/enums.dart';
import '../../models/media_model.dart';
import '../../utilities/utils.dart';


class ImageEmoji extends StatefulWidget {
  final EmojiInfo emoji;
  final bool isEmoji;
  final bool isLongPressed;

  const ImageEmoji({super.key, required this.emoji, required this.isEmoji, required this.isLongPressed});

  @override
  State<ImageEmoji> createState() => _ImageEmojiState();
}

class _ImageEmojiState extends State<ImageEmoji> {
  final imageKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox? imageBox = imageKey.currentContext?.findRenderObject() as RenderBox?;
       widget.emoji.width = imageBox?.size.width ?? defaultEmojiWidth;
       widget.emoji.height = imageBox?.size.height ?? defaultEmojiHeight;
    });
    return Material(
      color: Colors.transparent,
      child: Container(
          decoration: widget.isLongPressed
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.red),
                )
              : null,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: widget.emoji.width,
                      maxHeight: widget.emoji.height,
                    ),
                    child: RepaintBoundary(
                      key: imageKey,
                      child:widget.emoji.imageType == ImageType.remote ? Image.network(
                        widget.emoji.image!,
                        width: widget.emoji.width,
                        height: widget.emoji.height,
                        fit: BoxFit.fill,
                      ) : Image.file(
                        File(widget.emoji.image.toString()),
                        width: widget.emoji.width,
                        height: widget.emoji.height,
                        fit: BoxFit.fill,
                      )
                    ),
                  ),
                ),
              ),
              widget.isLongPressed
                  ? Container(
                      padding: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                      ),
                      child: Text(
                        "Click to remove", //TODO
                        style:const TextStyle(fontSize: 12.0, color: Colors.red),
                      ))
                  : Container(),
            ],
          )),
    );

  }
}
