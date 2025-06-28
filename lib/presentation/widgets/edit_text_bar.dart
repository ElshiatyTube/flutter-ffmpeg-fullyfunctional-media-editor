import 'package:flutter/material.dart';

import '../cubit/media_editing/media_editing_cubit.dart';

class EditTextBar extends StatelessWidget implements PreferredSizeWidget {
  final MediaEditingCubit editingCubit;
  const EditTextBar({super.key, required this.editingCubit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
                editingCubit.cancelTextEditing();
            },
            icon: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              editingCubit.increaseFontSize();
            },
            // increaseFontSize,
            tooltip: 'Increase font size',
          ),
          IconButton(
            icon: const Icon(
              Icons.remove,
              color: Colors.white,
            ),
            onPressed: () {
             editingCubit.decreaseFontSize();
            },
            //decreaseFontSize,
            tooltip: 'Decrease font size',
          ),
          IconButton(
            icon: const Icon(
              Icons.format_align_left,
              color: Colors.white,
            ),
            onPressed: () {
              editingCubit.alignLeft();
            },
            //alignLeft,
            tooltip: 'Align left',
          ),
          IconButton(
            icon: const Icon(
              Icons.format_align_center,
              color: Colors.white,
            ),
            onPressed: () {
             editingCubit.alignRight();
            },
            //alignCenter,
            tooltip: 'Align Center',
          ),
          IconButton(
            icon: const Icon(
              Icons.format_align_right,
              color: Colors.white,
            ),
            onPressed: () {
             editingCubit.alignCenter();
            },
            //alignRight,
            tooltip: 'Align Right',
          ),
         /* IconButton(
            icon: const Icon(
              Icons.format_bold,
              color: Colors.white,
            ),
            onPressed: () {
              editingCubit.boldText();
            },
            //boldText,
            tooltip: 'Bold',
          ),*/
          IconButton(
            icon: const Icon(
              Icons.format_italic,
              color: Colors.white,
            ),
            onPressed: () {
            editingCubit.italicText();
            },
            // italicText,
            tooltip: 'Italic',
          ),
          IconButton(
            icon: const Icon(
              Icons.space_bar,
              color: Colors.white,
            ),
            onPressed: () {
              editingCubit.addLinesToText();
            },
            //addLinesToText,
            tooltip: 'Add New Line',
          ),
          Tooltip(
            message: 'Red',
            child: GestureDetector(
                onTap: () {
                 editingCubit.changeTextColor(Colors.red,'red');
                },
                // changeTextColor(Colors.red),
                child: const CircleAvatar(
                  radius: 10.0,
                  backgroundColor: Colors.red,
                )),
          ),
          const SizedBox(
            width: 5,
          ),
          Tooltip(
            message: 'White',
            child: GestureDetector(
                onTap: () {
              editingCubit.changeTextColor(Colors.white,'white');
                },
                // changeTextColor(Colors.white),
                child: const CircleAvatar(
                  radius: 10.0,
                  backgroundColor: Colors.white,
                )),
          ),
          const SizedBox(
            width: 5,
          ),
          Tooltip(
            message: 'Black',
            child: GestureDetector(
                onTap: () {
                editingCubit.changeTextColor(Colors.black,'black');
                },
                //() => changeTextColor(Colors.black),
                child: const CircleAvatar(
                  radius: 10.0,
                  backgroundColor: Colors.black,
                )),
          ),
          const SizedBox(
            width: 5,
          ),
          Tooltip(
            message: 'Blue',
            child: GestureDetector(
                onTap: () {
               editingCubit.changeTextColor(Colors.blue,'blue');
                },
                //() => changeTextColor(Colors.blue),
                child: const CircleAvatar(
                  radius: 10.0,
                  backgroundColor: Colors.blue,
                )),
          ),
          const SizedBox(
            width: 5,
          ),
          Tooltip(
            message: 'Yellow',
            child: GestureDetector(
                onTap: () {
                editingCubit.changeTextColor(Colors.yellow,'yellow');
                },
                //() => changeTextColor(Colors.yellow),
                child: const CircleAvatar(
                  radius: 10.0,
                  backgroundColor: Colors.yellow,
                )),
          ),
          const SizedBox(
            width: 5,
          ),
          Tooltip(
            message: 'Green',
            child: GestureDetector(
                onTap: () {
                editingCubit.changeTextColor(Colors.green,'green');
                },
                //() => changeTextColor(Colors.green),
                child: const CircleAvatar(
                  radius: 10.0,
                  backgroundColor: Colors.green,
                )),
          ),
          const SizedBox(
            width: 5,
          ),
          Tooltip(
            message: 'Orange',
            child: GestureDetector(
                onTap: () {
                 editingCubit.changeTextColor(Colors.orange,'orange');
                },
                //() => changeTextColor(Colors.orange),
                child: const CircleAvatar(
                  radius: 10.0,
                  backgroundColor: Colors.orange,
                )),
          ),
          const SizedBox(
            width: 5,
          ),
          Tooltip(
            message: 'Pink',
            child: GestureDetector(
                onTap: () {
                  editingCubit.changeTextColor(Colors.pink,'pink');
                },
                //() => changeTextColor(Colors.pink),
                child: const CircleAvatar(
                  radius: 10.0,
                  backgroundColor: Colors.pink,
                )),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}


