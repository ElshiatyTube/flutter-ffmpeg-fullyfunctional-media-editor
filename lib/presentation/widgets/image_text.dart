import 'package:flutter/material.dart';

import '../../models/media_model.dart';


///responsive text size

class ImageText extends StatelessWidget {
  final TextInfo textInfo;

  const ImageText({
    super.key,
    required this.textInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
          decoration: textInfo.isLongPressed
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.red),
                )
              : null,
          child: LayoutBuilder(builder: (context, constraint) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    child: Text(
                      textInfo.text,
                      textAlign: textInfo.textAlign,
                      style: TextStyle(
                        fontSize: textInfo.fontSize,
                        fontWeight: textInfo.fontWeight,
                        fontStyle: textInfo.fontStyle,
                        color: textInfo.color,
                        fontFamily: textInfo.fontFamily,
                      ),
                    ),
                  ),
                ),
                textInfo.isLongPressed
                    ? Container(
                    padding: const EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white,
                    ),
                    child: const Text(
                      'Click to remove',
                      style: TextStyle(fontSize: 12.0, color: Colors.red),
                    ))
                    : const SizedBox.shrink(),
              ],
            );
          })),
    );
  }
}
