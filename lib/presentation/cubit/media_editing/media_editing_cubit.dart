import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../enums/enums.dart';
import '../../../models/media_model.dart';
import '../../../utilities/ffmpeg_funcs.dart';
import '../../../utilities/utils.dart';
import '../setup/setup_cubit.dart';
import '../sound/sound_cubit.dart';

part 'media_editing_state.dart';

class MediaEditingCubit extends Cubit<MediaEditingState> {
  MediaEditingCubit({required this.setupCubit, required this.soundCubit})
      : super(MediaEditingState(
          medias: setupCubit.state.medias,
          selectedMedia: setupCubit.state.medias.isNotEmpty ? setupCubit.state.medias.first : null,
        ));

  BuildContext? context;

  static MediaEditingCubit get(context) => BlocProvider.of<MediaEditingCubit>(context);

  void setScreenContext(BuildContext context) {
    this.context = context;
  }

  final SetupCubit setupCubit;
  final SoundCubit soundCubit;

  List<MediaModel> get medias => state.medias;

  MediaModel get selectedMedia => state.selectedMedia!;
  Size? get shaderSize => state.shaderSize;
  double? get devicePixels => state.devicePixels;
  EmojiInfo? get pressedEmoji => state.pressedEmoji;
  TextInfo? get currentEditingText => state.currentEditingText;

  Future<void> selectMedia(MediaModel media) async {
    emit(state.copyWith(selectedMedia: media));
    await toggleVideoWidget();
    emit(state.copyWith(status: MediaEditingStatus.mediaSelected));
  }

  Future<void> pickImageAddOverlay() async {
    String? imagePath = await pickImageFromGalleryUtil();
    if (imagePath == null) {
      emit(state.copyWith(status: MediaEditingStatus.pickImageError, error: 'Error picking image'));
      return;
    }
    String renamedPath = await renameFilePath(filePath: imagePath, dirName: 'media');
    await addNewEmoji(imagePath: renamedPath, isGif: imagePath.contains('.gif'), imageType: ImageType.local);
    emit(state.copyWith(status: MediaEditingStatus.pickImageSuccess));
  }

  Future<void> cropImage(BuildContext context) async {
    if (selectedMedia.filePath == null) return;
    File? imageFile = File(selectedMedia.filePath!);
    if (selectedMedia.mediaType == MediaType.remoteImage) {
      showLoadingDialogGif(context: context, dismiss: false);
      try {
        Uint8List mediaBytes = await getFileBytesFromUrl(selectedMedia.filePath!);
        imageFile = await getMediaFileFromBytes(mediaBytes: mediaBytes, mediaUrl: selectedMedia.filePath!);
        pop(); //pop loading dialog
      } catch (e) {
        pop(); //pop loading dialog
        return;
      }
    }
    if (imageFile == null) return;
    CroppedFile? croppedFile = await cropImageUtil(imagePath: imageFile.path);
    if (croppedFile == null) return;
    selectedMedia.filePath = croppedFile.path;
    selectedMedia.isCropped = true;
    selectedMedia.mediaType = MediaType.localImage;
    emit(state.copyWith(status: MediaEditingStatus.cropImage));
  }

  Future<void> toggleVideoWidget({Function? onEmit}) async {
    emit(state.copyWith(showVideoWidget: false));
    if (selectedMedia.mediaType == MediaType.localVideo || selectedMedia.mediaType == MediaType.remoteVideo) {
      emit(state.copyWith(status: MediaEditingStatus.toggleVideoWidget));
      await Future.delayed(const Duration(milliseconds: 100), () {
        emit(state.copyWith(showVideoWidget: true));
      });
    }
    emit(state.copyWith(status: MediaEditingStatus.toggleVideoWidget));
  }

  //#region Text Editing
  final TextEditingController textEditingController = TextEditingController();

  setCurrentTextToEdit({required TextInfo selectedText}) {
    emit(state.copyWith(currentEditingText: selectedText, status: MediaEditingStatus.selectText));
  }

  void cancelTextEditing() {
    emit(state.copyWith(currentEditingText: null, status: MediaEditingStatus.cancelTextEditing));
  }

  void longPressText({required TextInfo selectedText}) {
    selectedText.isLongPressed = true;
    emit(state.copyWith(status: MediaEditingStatus.longPressItem));
  }

  removeText({required TextInfo selectedText}) {
    selectedMedia.texts.remove(selectedText);
    emit(state.copyWith(currentEditingText: null, status: MediaEditingStatus.removeText));
  }
  disposeTextEditing() {
    textEditingController.dispose();
  }

  void clearAllTextsLongPress() {
    if (selectedMedia.texts.any((element) => element.isLongPressed == true)) {
      for (var element in selectedMedia.texts) {
        element.isLongPressed = false;
      }
      emit(state.copyWith(currentEditingText: null, status: MediaEditingStatus.clearAllTextsLongPress));
    }
  }

  changeTextColor(Color color, String colorName) {
    currentEditingText!.color = color;
    currentEditingText!.colorName = colorName;
    emit(state.copyWith(status: MediaEditingStatus.editText));
  }

  increaseFontSize() {
    currentEditingText!.fontSize += 2;
    emit(state.copyWith(status: MediaEditingStatus.editText));
  }

  decreaseFontSize() {
    currentEditingText!.fontSize -= 2;
    emit(state.copyWith(status: MediaEditingStatus.editText));
  }

  alignLeft() {
    currentEditingText!.textAlign = TextAlign.left;
    emit(state.copyWith(status: MediaEditingStatus.editText));
  }

  alignCenter() {
    currentEditingText!.textAlign = TextAlign.center;
    emit(state.copyWith(status: MediaEditingStatus.editText));
  }

  alignRight() {
    currentEditingText!.textAlign = TextAlign.right;
    emit(state.copyWith(status: MediaEditingStatus.editText));
  }

  boldText() {
    if (currentEditingText!.fontWeight == FontWeight.bold) {
      currentEditingText!.fontWeight = FontWeight.normal;
    } else {
      currentEditingText!.fontWeight = FontWeight.bold;
    }
    emit(state.copyWith(status: MediaEditingStatus.editText));
  }

  italicText() {
    if (currentEditingText!.fontStyle == FontStyle.italic) {
      currentEditingText!.fontStyle = FontStyle.normal;
    } else {
      currentEditingText!.fontStyle = FontStyle.italic;
    }
    emit(state.copyWith(status: MediaEditingStatus.editText));
  }

  addLinesToText() {
    if (currentEditingText!.text.contains('\n')) {
      currentEditingText!.text = currentEditingText!.text.replaceAll('\n', ' ');
    } else {
      currentEditingText!.text = currentEditingText!.text.replaceAll(' ', '\n');
    }
    emit(state.copyWith(status: MediaEditingStatus.editText));
  }

  void addNewText(BuildContext context) {
    selectedMedia.texts.add(TextInfo(
        text: textEditingController.text,
        x: MediaQuery.of(context).size.width * 0.5,
        y: MediaQuery.of(context).size.height * 0.3,
        color: Colors.white,
        fontWeight: FontWeight.normal,
        colorName: 'white',
        fontStyle: FontStyle.normal,
        fontSize: 20,
        textAlign: TextAlign.left,
        isLongPressed: false, xPer: 0.5, yPer: 0.3));
    textEditingController.clear();
    emit(state.copyWith(status: MediaEditingStatus.addNewItem));
    Navigator.of(context).pop();
  }
  //#endregion

  //#region Emoji Editing

  Future<void> addNewEmoji({required String imagePath, bool isGif = false, ImageType imageType = ImageType.remote}) async {
    double height = defaultEmojiHeight;
    double width = defaultEmojiWidth;
    if (imageType == ImageType.local) {
      Size size = await getImageOrgSize(imagePath: imagePath, type: MediaType.localImage);
      height = size.height * 0.25;
      width = size.width * 0.25;
    }
    selectedMedia.emojis.add(
      EmojiInfo(
        image: imagePath,
        x: 0.0,
        y: 0.0,
        isGif: isGif,
        imageType: imageType,
        width: width,
        height: height,
        isEmoji: true,
      ),
    );
    emit(state.copyWith(status: MediaEditingStatus.addNewItem));
  }

  removeEmoji({required EmojiInfo selectedEmoji}) {
    selectedMedia.emojis.remove(selectedEmoji);
    emit(state.copyWith(pressedEmoji: null, status: MediaEditingStatus.removeEmoji));
  }

  increaseEmojiSize({required EmojiInfo selectedEmoji}) {
    selectedEmoji.width += 10;
    selectedEmoji.height += 10;
    emit(state.copyWith(status: MediaEditingStatus.changeEmojiSize));
  }
  decreaseEmojiSize({required EmojiInfo selectedEmoji}) {
    selectedEmoji.width -= 10;
    selectedEmoji.height -= 10;
    emit(state.copyWith(status: MediaEditingStatus.changeEmojiSize));
  }

  void longPressEmoji({required EmojiInfo emojiModel}) {
    emit(state.copyWith(pressedEmoji: emojiModel, status: MediaEditingStatus.longPressItem));
  }

  void clearAllEmojisLongPress() {
    emit(state.copyWith(pressedEmoji: null, status: MediaEditingStatus.clearAllEmojisLongPress));
  }
  //#endregion

  //#region Color Editing

  void addFilteredColor({required BuildContext context, required int index}) {
    selectedMedia.color = ColorFilterWithName.values[index];
    selectedMedia.colorOpacity = 0.5;
    if (index == 1) {
      //black and white
      selectedMedia.colorOpacity = 1.0;
    }
    emit(state.copyWith(status: MediaEditingStatus.addFilteredColor));
  }
  //#endregion

  void changeOpacity(double value) {
    selectedMedia.colorOpacity = value;
    emit(state.copyWith(status: MediaEditingStatus.changeOpacity));
  }

  void removeMediaItem({required BuildContext context, required MediaModel item}) {
    int mediaIndex = medias.indexOf(item);
    final newMedias = List<MediaModel>.from(medias);
    newMedias.removeAt(mediaIndex);

    if (item.durationInSeconds != null) {
      setupCubit.setCurrentTime(min(setupCubit.state.fixedTime, (setupCubit.state.currentTime) + (item.durationInSeconds as num)));
      setupCubit.setCurrentTime(max(0, setupCubit.state.currentTime));
    }

    if (newMedias.isNotEmpty) {
      emit(state.copyWith(medias: newMedias, selectedMedia: newMedias[0], status: MediaEditingStatus.removeMediaItem));
    }
    setupCubit.removeMediaEmitState();

    if (newMedias.isEmpty) {
      setupCubit.setCurrentTime(setupCubit.state.fixedTime);
      pop();
    }
    printDebug('removeMediaItem: \\${newMedias.length}');
  }

  Future<void> processMedia({bool saveToGallery = false, MediaModel? media}) async {
    final List<MediaProcessInfo> lastVideoPaths = [];
    emit(state.copyWith(status: MediaEditingStatus.loading));
    try {
      await Future.forEach(media == null ? medias : [media], (MediaModel post) async {
        if (post.filePath == null) return;
        if (post.isEdited && (post.mediaType == MediaType.remoteVideo || post.mediaType == MediaType.remoteImage)) {
          printDebug('mediaUrl: \\${post.filePath.toString()}');
          Uint8List mediaBytes = await getFileBytesFromUrl(post.filePath!);
          File? mediaFile = await getMediaFileFromBytes(mediaBytes: mediaBytes, mediaUrl: post.filePath!);
          post.filePath = mediaFile?.path;
          if (post.mediaType == MediaType.remoteVideo) {
            post.mediaType = MediaType.localVideo;
          } else if (post.mediaType == MediaType.remoteImage) {
            post.mediaType = MediaType.localImage;
          }
        }
        if (!post.isEdited && (post.mediaType == MediaType.remoteVideo || post.mediaType == MediaType.remoteImage)) {
          post.skipProcessing = true;
        }
      });
      await Future.forEach(media == null ? medias : [media], (MediaModel postData) async {
        if (postData.filePath == null) return;
        FFmpegKitConfig.enableLogCallback((log) {
          final message = log.getMessage();
          printDebug('FFmpegKitConfig: \\${message}');
        });
        if (postData.mediaType == MediaType.localImage || postData.mediaType == MediaType.remoteImage) {
          String colorOutPut = '';
          String textOutPut = '';
          String emojiVideoOutPut = '';
          String transposedOutPut = '';
          String finalOutPut = postData.filePath!;
          //color
          if (postData.color != ColorFilterWithName.transparent) {
            colorOutPut = await FfmpegFuncs.overLayColorOverMedia(
                path: postData.filePath!,
                color: postData.color,
                colorOpacity: postData.colorOpacity,
                type: postData.mediaType == MediaType.remoteVideo || postData.mediaType == MediaType.localVideo ? FfmpegMediaTypes.video : FfmpegMediaTypes.image,
                h: postData.mediaH!,
                w: postData.mediaW!);
            if (colorOutPut.isNotEmpty) finalOutPut = colorOutPut;
          }
          //text
          if (postData.texts.isNotEmpty) {
            textOutPut = await FfmpegFuncs.overLayText(
                path: finalOutPut, texts: postData.texts, isVideo: false, h: postData.mediaH!, w: postData.mediaW!);
            if (textOutPut.isNotEmpty) finalOutPut = textOutPut;
          }
          if (postData.emojis.isNotEmpty) {
            var value = await FfmpegFuncs.convertImageToVideo(
              imagePath: finalOutPut,
              height: postData.picked ? postData.mediaH! : shaderSize?.height ?? (postData.mediaH ?? 0),
              width: postData.picked ? postData.mediaW! : shaderSize?.width ?? (postData.mediaW ?? 0),
            );
            if (value.isNotEmpty) {
              //emoji

              emojiVideoOutPut = await FfmpegFuncs.overLayEmoji(
                path: value,
                emojis: postData.emojis,
                mediaPathType: FfmpegMediaTypes.video,
                cameraMedia: !postData.picked,
                height: postData.picked ? postData.mediaH! : shaderSize?.height ?? (postData.mediaH ?? 0),
                width: postData.picked ? postData.mediaW! : shaderSize?.width ?? (postData.mediaW ?? 0),
              );
              if (emojiVideoOutPut.isNotEmpty) finalOutPut = emojiVideoOutPut;
            }
          }

          if (postData.transpose != Transpose.none) {
            transposedOutPut = await FfmpegFuncs.rotateImage(imagePath: finalOutPut, transpose: postData.transpose);
            if (transposedOutPut.isNotEmpty) finalOutPut = transposedOutPut;
          }
          lastVideoPaths.add(MediaProcessInfo(
              path: finalOutPut,
              isNew: postData.isNew ?? false,
              isEdited: postData.isEdited,
              mediaId: postData.id,
              mediaType: emojiVideoOutPut.isNotEmpty ? MediaType.localVideo : postData.mediaType,
              videoThumbnail: emojiVideoOutPut.isNotEmpty ? postData.filePath : postData.videThumbPath,
              mediaW: postData.mediaW,
              mediaH: postData.mediaH,
              durationInSeconds: postData.durationInSeconds));
        } else {
          String colorOutPut = '';
          String emojiOutPut = '';
          String textOutPut = '';
          String finalOutPut = postData.filePath!;

          if (postData.color != ColorFilterWithName.transparent) {
            colorOutPut = await FfmpegFuncs.overLayColorOverMedia(
                color: postData.color,
                colorOpacity: postData.colorOpacity,
                path: finalOutPut,
                type: FfmpegMediaTypes.video,
                h: postData.mediaH!,
                w: postData.mediaW!);
            if (colorOutPut.isNotEmpty) finalOutPut = colorOutPut;
          }
          if (postData.texts.isNotEmpty) {
            textOutPut = await FfmpegFuncs.overLayText(texts: postData.texts, path: finalOutPut, isVideo: true, h: postData.mediaH!, w: postData.mediaW!);
            if (textOutPut.isNotEmpty) finalOutPut = textOutPut;
          }
          if (postData.emojis.isNotEmpty) {
            emojiOutPut = await FfmpegFuncs.overLayEmoji(
              path: finalOutPut,
              emojis: postData.emojis,
              mediaPathType: FfmpegMediaTypes.video,
              cameraMedia: !postData.picked,
              height: postData.picked ? postData.mediaH! : shaderSize?.height ?? (postData.mediaH ?? 0),
              width: postData.picked ? postData.mediaW! : shaderSize?.width ?? (postData.mediaW ?? 0),
            );
            if (emojiOutPut.isNotEmpty) {
              printDebug('emojiOutPutSuc');
              finalOutPut = emojiOutPut;
            }
          }
          if (postData.skipProcessing) {
            printDebug('skipProcessing');
            lastVideoPaths.add(MediaProcessInfo(
                path: postData.filePath!,
                isNew: false,
                isEdited: false,
                mediaId: postData.id,
                mediaType: postData.mediaType,
                videoThumbnail: postData.videThumbPath,
                short: postData.short,
                mediaW: postData.mediaW,
                mediaH: postData.mediaH,
                durationInSeconds: postData.durationInSeconds));
          } else {
            String short = await FfmpegFuncs.convertVideoToGif(path: finalOutPut);
            File? finalThumb = await FfmpegFuncs.getVideoThumbnail(finalOutPut);
            lastVideoPaths.add(MediaProcessInfo(
                path: finalOutPut,
                isNew: postData.isNew ?? false,
                isEdited: postData.isEdited,
                mediaId: postData.id,
                mediaType: postData.mediaType,
                videoThumbnail: finalThumb?.path ?? postData.videThumbPath,
                short: short,
                mediaW: postData.mediaW,
                mediaH: postData.mediaH,
                durationInSeconds: postData.durationInSeconds));
          }
        }
      });
      printDebug('finishProcessing: \\${lastVideoPaths.length}');
      emit(state.copyWith(status: MediaEditingStatus.success, processedMedia: lastVideoPaths, saveToGallery: saveToGallery));
    } catch (e) {
      printDebug('errorProcessing: \\${e}');
      emit(state.copyWith(status: MediaEditingStatus.error, error: e.toString()));
    }
  }

  void rotateImage() {
    selectedMedia.rotationAngle += 90 * 3.141592653589793 / 180;
    if (selectedMedia.rotationDegree == 270) {
      selectedMedia.rotationDegree = 0;
    } else {
      selectedMedia.rotationDegree = selectedMedia.rotationDegree + 90;
    }
    printDebug('selectedMedia.rotationAngle: \\${selectedMedia.rotationAngle} , selectedMedia.rotationDegree: \\${selectedMedia.rotationDegree}');

    switch (selectedMedia.rotationDegree) {
      case 0:
        selectedMedia.transpose = Transpose.none;
        break;
      case 90:
        selectedMedia.transpose = Transpose.clock;
        break;
      case 180:
        selectedMedia.transpose = Transpose.upSideDown;
        break;
      case 270:
        selectedMedia.transpose = Transpose.counterClock;
        break;
    }

    printDebug('selectedMedia.transpose: \\${selectedMedia.transpose.val}, \\${selectedMedia.transpose.stringVal}');

    emit(state.copyWith(status: MediaEditingStatus.rotateImage));
  }

  void setShaderSize(Size size, double devicePixelRatio) {
    emit(state.copyWith(shaderSize: size, devicePixels: devicePixelRatio));
  }

  void pop() {
    if (context != null && context!.mounted && Navigator.canPop(context!)) {
      Navigator.pop(context!);
    }
  }
}
