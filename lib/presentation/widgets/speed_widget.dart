import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/setup/setup_cubit.dart';
import '../cubit/setup/setup_state.dart';
import '../../enums/enums.dart';

class SpeedWidget extends StatelessWidget {
  const SpeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, state) {
        final cubit = SetupCubit.get(context);
        if (state.hideSpeedContainer) return SizedBox.shrink();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: VideoSpeedEnum.values.map((speed) {
            final isSelected = state.selectedSpeed == speed;
            return GestureDetector(
              onTap: () => cubit.speed(speed: speed),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pink : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  speed.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
