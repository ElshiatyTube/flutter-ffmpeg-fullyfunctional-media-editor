import 'package:flutter/material.dart';


class ShareBtn extends StatelessWidget {
  final Function()? onTap;
  final bool isEdit;
  const ShareBtn({super.key,required this.onTap, required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onTap,
      child: Container(
        width: 170,
        height: 40.0,
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.white,width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children:  [
              Expanded(
                child: Text(
                  isEdit ? 'Finish editing' : 'Process media',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_right,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
