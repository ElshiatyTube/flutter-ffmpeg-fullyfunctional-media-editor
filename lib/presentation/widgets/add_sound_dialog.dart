import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/sound/sound_cubit.dart';
import '../cubit/sound/sound_state.dart';

class AddSoundDialog extends StatefulWidget {
  const AddSoundDialog({Key? key}) : super(key: key);

  @override
  State<AddSoundDialog> createState() => _AddSoundDialogState();
}

class _AddSoundDialogState extends State<AddSoundDialog> {
  late SoundCubit soundCubit;

  @override
  void initState() {
    super.initState();
    soundCubit = SoundCubit.get(context);
    soundCubit.initAudioObject();
  }

  @override
  void dispose() {
    soundCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SoundCubit, SoundState>(
      listener: (BuildContext _, state) {
        if (state.status == SoundStatus.selected) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Add Sound'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Upload'),
              onPressed: () {
                soundCubit.pickSoundFromLocal();
              },
            ),
          ],
        ),
        body: BlocBuilder<SoundCubit, SoundState>(
          builder: (context, state) {
            // Custom loading overlay for picking sound from local
            final showOverlay = state.status == SoundStatus.loading && state.isLocal == true;
            return Stack(
              children: [
                if (state.status == SoundStatus.loading && state.sounds.isEmpty)
                  const Center(child: CircularProgressIndicator()),
                if (state.status == SoundStatus.error)
                  Center(child: Text(state.errorMessage ?? 'Failed to load sounds.')),
                if (state.sounds.isEmpty && state.status != SoundStatus.loading && state.status != SoundStatus.error)
                  const Center(child: Text('No sounds found.')),
                if (state.sounds.isNotEmpty)
                  ListView.builder(
                    itemCount: state.sounds.length,
                    itemBuilder: (BuildContext context, int index) {
                      final sound = state.sounds[index];
                      final isPlaying = state.isPlaying && state.soundPlaying == sound;
                      final isSelected = state.selectedSound == sound;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: const Icon(Icons.music_note, size: 40, color: Colors.pink),
                        title: Text(sound.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${(sound.duration ?? 0.0).toStringAsFixed(1)}s'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                soundCubit.controlSound(song: sound, index: index);
                              },
                              icon: Icon(
                                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                color: Colors.pink,
                                size: 30,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                soundCubit.selectSound(song: sound, index: index);
                              },
                              icon: Icon(
                                isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                color: isSelected ? Colors.green : Colors.grey,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                if (showOverlay)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
