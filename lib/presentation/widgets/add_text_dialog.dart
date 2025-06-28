import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AddTextDialog extends StatelessWidget {
  final Function()? onTap;
  final TextEditingController textEditingController;

  const AddTextDialog(
      {super.key, required this.onTap, required this.textEditingController});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Dialog(
      alignment: const Alignment(0.0, 0.6),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              // expands: false,
              maxLines: 10,
              controller: textEditingController,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        width: 1, color: Theme.of(context).primaryColorLight)),
                labelStyle:
                const TextStyle(color: Colors.black38, fontSize: 16),
                labelText: 'Caption',
                prefixIcon: Icon(
                  CupertinoIcons.text_cursor,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              alignment: Alignment.bottomCenter,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Container(
                width: width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10)),
                child: TextButton(
                  onPressed: onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Add",
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
