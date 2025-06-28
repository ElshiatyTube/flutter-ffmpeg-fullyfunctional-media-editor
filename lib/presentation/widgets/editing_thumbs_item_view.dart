import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../enums/enums.dart';
import '../../utilities/utils.dart';

class EditingThumbsItemView extends StatefulWidget {
  final String image;
  final ImageType imageType;
  final Function onTap;
  final bool isSelected;
  final int? durationInSeconds;

  const EditingThumbsItemView({
    super.key,
    required this.image,
    required this.onTap,
    required this.imageType,
    required this.isSelected,
    this.durationInSeconds,
  });

  @override
  State<EditingThumbsItemView> createState() => _EditingThumbsItemViewState();
}

class _EditingThumbsItemViewState extends State<EditingThumbsItemView> {
  @override
  Widget build(BuildContext context) {
    //printDebug('typeThumb: ${widget.imageType.name} path ${widget.image}');
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.18,
                //height: MediaQuery.of(context).size.width * 0.18,
                decoration: BoxDecoration(
                  border: Border.all(
                    color:Colors.white,
                    width: widget.isSelected ? 3.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: !widget.image.contains('http')
                      ? Image.file(File(widget.image), fit: BoxFit.cover)
                      : Image.network(widget.image, fit: BoxFit.cover),
                ),
              ),
            ),
            if (widget.durationInSeconds != null) ...[
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      durationToString(widget.durationInSeconds!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                  ))
            ]
          ],
        ),
      ),
    );
  }
}
