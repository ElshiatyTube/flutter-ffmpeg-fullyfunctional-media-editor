import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../cubit/setup/setup_cubit.dart';


class NavToEditWidget extends StatelessWidget {
  final SetupCubit setupCubit;
  final GestureTapCallback onTap;
  const NavToEditWidget({super.key, required this.setupCubit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: setupCubit.state.medias.isNotEmpty,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 24, top: 16.0),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.right_chevron,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    setupCubit.state.medias.length.toString(),
                    style: const TextStyle(
                      color: Colors.pinkAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
