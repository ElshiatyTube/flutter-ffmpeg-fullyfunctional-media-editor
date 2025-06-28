import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/cubit/sound/sound_state.dart';
import 'package:flutter_ffmpeg_media_editor/utilities/ffmpeg_funcs.dart';
import 'package:path/path.dart' as p;

import '../../../models/sound_model.dart';
import '../../../utilities/utils.dart';

class SoundCubit extends Cubit<SoundState> {
  SoundCubit() : super(SoundState(sounds:  [ //TODO: dynamic sounds list
    SoundModel(id: '1', name: 'Acoustic Breeze', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
    SoundModel(id: '2', name: 'Funky Element', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'),
    SoundModel(id: '3', name: 'Happy Day', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'),
  ]));

  static SoundCubit get(context) => BlocProvider.of<SoundCubit>(context);

  void initAudioObject() {
    emit(state.copyWith(audioPlayer: AudioPlayer()));
  }


  Future<void> controlSound(
      {required SoundModel song, required int index}) async {
    printDebug('SoundUrl: ${song.url}');
    emit(state.copyWith(status: SoundStatus.loading));
    final player = state.audioPlayer ?? AudioPlayer();
    if (player.state == PlayerState.playing) {
      await player.pause();
    }
    if (!state.isPlaying) {
      await player.play(UrlSource(song.url)).then((value) {
        emit(state.copyWith(
          isPlaying: true,
          status: SoundStatus.playing,
          soundPlaying: song,
        ));
      }).catchError((onError) {
        debugPrint("Audio Play error: ${onError.toString()}");
        emit(state.copyWith(
          status: SoundStatus.error,
          errorMessage: onError.toString(),
        ));
      });
    } else {
      await player.pause();
      emit(state.copyWith(
        isPlaying: false,
        status: SoundStatus.paused,
      ));
      if (song != state.soundPlaying) {
        controlSound(song: song, index: index);
      }
    }
    emit(state.copyWith(soundPlaying: song));
  }

  Future<void> selectSound(
      {required SoundModel song, required int index}) async {
    emit(state.copyWith(status: SoundStatus.loading));
    final player = state.audioPlayer ?? AudioPlayer();
    if (player.state == PlayerState.playing) {
      await player.pause();
    }
    final duration = await getAudioDurationInSec(url: song.url);
    song.duration = duration;
    emit(state.copyWith(
      selectedSound: song,
      status: SoundStatus.selected,
      isLocal: false,
    ));
  }

  Future<double> getAudioDurationInSec({required String url}) async {
    try {
      var duration = await FfmpegFuncs.getFileDuration(url);
      return duration;
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> removeSound() async {
    emit(state.copyWith(selectedSound: null, status: SoundStatus.removed));
  }

  Future<void> pickSoundFromLocal() async {
    try {
      FilePickerResult? result = await pickFiles(
          allowedExtensions: ['mp3'],
          fileType: FileType.custom,
          allowMultiple: false);
      if (result != null) {
        emit(state.copyWith(status: SoundStatus.loading));
        File pickedFileData = File(result.files.single.path!);
        String basename = p.basename(pickedFileData.path);
        String renamedAudioPath = await renameFilePath(
            filePath: pickedFileData.path, dirName: 'audios');
        final localSound =
            SoundModel.localSound(name: basename, url: renamedAudioPath);
        localSound.duration = await getAudioDurationInSec(url: localSound.url);
        emit(state.copyWith(
          selectedSound: localSound,
          status: SoundStatus.selected,
          isLocal: true,
        ));
      } else {
        return;
      }
    } catch (e) {
      printDebug("error pick image: $e");
      emit(state.copyWith(
          status: SoundStatus.error, errorMessage: e.toString()));
    }
  }
  Future<void> dispose() async {
    state.audioPlayer?.dispose();
  }

  @override
  Future<void> close() {
   dispose();
    return super.close();
  }
}
