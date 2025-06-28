import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/cubit/video_player/video_player_cubit.dart';

import '../../enums/enums.dart';
import '../../models/media_model.dart';
import '../../utilities/utils.dart';
import '../cubit/media_editing/media_editing_cubit.dart';
import '../widgets/drag_emoji.dart';
import '../widgets/drag_text.dart';
import '../widgets/edit_text_bar.dart';
import '../widgets/editing_thumbs_item_view.dart';
import '../widgets/share_btn.dart';
import '../widgets/sound_lable_widget.dart';
import '../widgets/video_editing_side_menu.dart';
import '../widgets/video_player_widget.dart';

class MediaEditingScreen extends StatefulWidget {
  const MediaEditingScreen({super.key});

  @override
  State<MediaEditingScreen> createState() => _MediaEditingScreenState();
}

class _MediaEditingScreenState extends State<MediaEditingScreen> {
  late MediaEditingCubit _editingCubit;

  final GlobalKey shaderKey = GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _editingCubit = MediaEditingCubit.get(context)..setScreenContext(context);
  }

  @override
  void dispose() {
    _editingCubit.disposeTextEditing();
    super.dispose();
  }

  void getShaderMaskSize(MediaEditingState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (shaderKey.currentContext == null) return;
        final RenderBox renderBox =
            shaderKey.currentContext!.findRenderObject() as RenderBox;
        printDebug('renderBox.size: \\${renderBox.size}');
        _editingCubit.setShaderSize(renderBox.size, MediaQuery.of(context).devicePixelRatio);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MediaEditingCubit, MediaEditingState>(
      listener: (BuildContext _, MediaEditingState state) async {
        if (state.status == MediaEditingStatus.loading) {
          // show loading
        }
        if (state.status == MediaEditingStatus.error) {
          _editingCubit.pop(); // pop loading
        }
        if (state.status == MediaEditingStatus.success) {
          _editingCubit.pop(); // pop loading
          if (state.saveToGallery && state.processedMedia != null) {
            await Future.forEach(state.processedMedia!, (media) async => await saveNetworkImage(media.path, isVideo: checkVideoType(media.mediaType)));
            //showToast(msg: 'saved_gallery', state: ToastedStates.SUCCESS); TODO
            return;
          }
        }
        // Optionally handle edit/emoji/crop/rotate states if needed
      },
      builder: (BuildContext context, MediaEditingState state) {
        getShaderMaskSize(state);
        final selectedMedia = state.selectedMedia;
        return SafeArea(
          child: GestureDetector(
            onTap: () async {
              printDebug('press');
              if (selectedMedia?.emojis.isNotEmpty ?? false) {
                context.read<MediaEditingCubit>().clearAllEmojisLongPress();
              }
              if (selectedMedia?.texts.isNotEmpty ?? false) {
                context.read<MediaEditingCubit>().clearAllTextsLongPress();
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              key: scaffoldKey,
              backgroundColor: Colors.black87,
              body: Stack(
                children: [
                  ShaderMask(
                    blendMode: selectedMedia?.color != ColorFilterWithName.whiteRadiant ? BlendMode.color : BlendMode.screen,
                    shaderCallback: (Rect bounds) {
                      if (selectedMedia?.color != ColorFilterWithName.whiteRadiant) {
                        return LinearGradient(
                          colors: selectedMedia?.color != ColorFilterWithName.transparent
                              ? [
                                  selectedMedia!.color.filter[0].withOpacity(selectedMedia.colorOpacity),
                                  Colors.transparent
                                ]
                              : [Colors.transparent, Colors.transparent],
                          stops: const [1, 0],
                        ).createShader(bounds);
                      }
                      return const LinearGradient(
                        colors: [Colors.white, Colors.transparent, Colors.white, Colors.transparent],
                        stops: [0.1, 0.1, 0.1, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        transform: GradientRotation(1.1),
                      ).createShader(bounds);
                    },
                    child: Stack(
                      children: [
                        if (selectedMedia?.mediaType == MediaType.localImage ||
                            selectedMedia?.mediaType == MediaType.remoteImage)
                          Center(
                            key: shaderKey,
                            child: (selectedMedia?.mediaType == MediaType.localImage)
                                ? Transform.rotate(
                                    angle: max(0, selectedMedia?.rotationAngle ?? 0),
                                    child: Image.file(File(selectedMedia?.filePath ?? '')),
                                  )
                                : Transform.rotate(
                                    angle: max(0, selectedMedia?.rotationAngle ?? 0),
                                    child: Image.network(selectedMedia?.filePath ?? ''),
                                  ),
                          )
                        else if (state.showVideoWidget)
                          Center(
                            child: SizedBox(
                              key: shaderKey,
                              width: selectedMedia?.mediaW,
                              height: selectedMedia?.mediaH,
                              child: BlocProvider(
                                create: (_) => VideoPlayerCubit(
                                  ctx: context,
                                  videoThumbnail: selectedMedia?.videThumbPath,
                                  mediaModel: selectedMedia,
                                  currentVideo: selectedMedia?.filePath ?? '',
                                  videoType: selectedMedia?.mediaType == MediaType.localVideo
                                      ? VideoType.local
                                      : VideoType.remote,
                                ),
                                child: const VideoPlayerWidget(
                                  isVideoEditingStyle: true,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SoundLabelWidget(
                    fromCamera: false,
                    sound: selectedMedia?.sound,
                  ),
                  if (state.pressedEmoji != null) ...[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.09),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.read<MediaEditingCubit>().decreaseEmojiSize(selectedEmoji: state.pressedEmoji!);
                              },
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<MediaEditingCubit>().increaseEmojiSize(selectedEmoji: state.pressedEmoji!);
                              },
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 50,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                  for (int i = 0; i < (selectedMedia?.texts.length ?? 0); i++) ...[
                    DragText(
                      currentText: selectedMedia!.texts[i],
                      onDragEnd: (TextInfo selectedText, DraggableDetails drag) {
                        RenderBox box = shaderKey.currentContext!.findRenderObject() as RenderBox;
                        printDebug('offset: \\${drag.offset.dy}, \\${drag.offset.dx}');
                        Offset position = box.localToGlobal(drag.offset);
                        double y = position.dy;
                        double x = position.dx;
                        printDebug('dx:\\$x dy:\\$y');
                        double yPercentage = y / box.size.height;
                        double xPercentage = x / box.size.width;
                        printDebug('videoHeight: \\${box.size.height} ,videoWid \\${box.size.width} ,yPercentage: \\$yPercentage ,xPercentage: \\$xPercentage');
                        setState(() {
                          selectedText.y = y;
                          selectedText.x = x;
                          selectedText.yPer = yPercentage;
                          selectedText.xPer = xPercentage;
                        });
                      },
                      onLongPress: (TextInfo selectedText) {
                        context.read<MediaEditingCubit>().longPressText(selectedText: selectedText);
                      },
                      onTapToEdit: (TextInfo selectedText) {
                        context.read<MediaEditingCubit>().setCurrentTextToEdit(selectedText: selectedText);
                      },
                      removeText: (TextInfo selectedText) {
                        printDebug('removeTextClick');
                        context.read<MediaEditingCubit>().removeText(selectedText: selectedText);
                      },
                    ),
                  ],
                  for (int i = 0; i < (selectedMedia?.emojis.length ?? 0); i++) ...[
                    DragEmoji(
                      selectedEmoji: selectedMedia!.emojis[i],
                      isPressed: selectedMedia.emojis[i] == state.pressedEmoji,
                      myContext: context,
                      onDragEnd: (EmojiInfo selectedEmoji, DraggableDetails drag) {
                        RenderBox box = shaderKey.currentContext!.findRenderObject() as RenderBox;
                        printDebug('offset: \\${drag.offset.dy}, \\${drag.offset.dx}');
                        Offset position = box.localToGlobal(drag.offset);
                        double y = position.dy;
                        double x = position.dx;
                        printDebug('dx:\\$x dy:\\$y');
                        double yPercentage = y / box.size.height;
                        double xPercentage = x / box.size.width;
                        printDebug('videoHeight: \\${box.size.height} ,videoWid \\${box.size.width} ,yPercentage: \\$yPercentage ,xPercentage: \\$xPercentage');
                        setState(() {
                          selectedEmoji.y = y;
                          selectedEmoji.x = x;
                          selectedEmoji.yPer = yPercentage;
                          selectedEmoji.xPer = xPercentage;
                        });
                      },
                      onPress: (EmojiInfo selectedEmoji) {
                        context.read<MediaEditingCubit>().longPressEmoji(emojiModel: selectedEmoji);
                      },
                      removeItem: (EmojiInfo selectedEmoji) {
                        printDebug('removeItemClick');
                        context.read<MediaEditingCubit>().removeEmoji(selectedEmoji: selectedEmoji);
                      },
                    ),
                  ],
                  Align(
                    alignment: Alignment.topRight,
                    child: VideoEditingSideMenu(
                      scaffoldKey: scaffoldKey,
                      isVideo: selectedMedia?.mediaType == MediaType.localVideo ||
                          selectedMedia?.mediaType == MediaType.remoteVideo,
                      textController: _editingCubit.textEditingController,
                      rotateImage: () {
                        context.read<MediaEditingCubit>().rotateImage();
                      },
                      addText: () {
                        context.read<MediaEditingCubit>().addNewText(context);
                      },
                      pickImageAndOverlay: selectedMedia?.mediaType == MediaType.localVideo || selectedMedia?.mediaType == MediaType.remoteVideo
                          ? () async {
                              await context.read<MediaEditingCubit>().pickImageAddOverlay();
                            }
                          : null,
                      selectEmoji: (EmojiModel emoji) =>
                          context.read<MediaEditingCubit>().addNewEmoji(imagePath: emoji.image, isGif: emoji.isGif),
                      selectColoredFilter: (colorIndex) =>
                          context.read<MediaEditingCubit>().addFilteredColor(context: context, index: colorIndex),
                      saveToGallery: () async {
                        showLoadingDialogGif(context: context, dismiss: false);
                        await context.read<MediaEditingCubit>().processMedia(saveToGallery: true, media: selectedMedia);
                      },
                      onChangeOpacity: (double value) {
                        context.read<MediaEditingCubit>().changeOpacity(value);
                      },
                      cropImage: () {
                        context.read<MediaEditingCubit>().cropImage(context);
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(18.0),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.keyboard_arrow_left_rounded,
                                color: Colors.white, size: 30.0),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(18.0),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              showBasicAlertDialog(
                                  title: 'Delete',
                                  message: 'Are you sure you want to delete this media?',
                                  context: context,
                                  icon: const Icon(Icons.delete),
                                  onCancelBtnText: 'Cancel',
                                  onConfirmBtnText: 'Delete',
                                  onConfirmClick: () {
                                    Navigator.pop(context);
                                    context.read<MediaEditingCubit>().removeMediaItem(
                                        context: context,
                                        item: selectedMedia!);
                                  },
                                  onCancelClick: () {
                                    Navigator.pop(context);
                                  },
                                  onConfirmColor: Colors.red,
                                  onCancelColor: Colors.grey,
                                  dismissible: true);
                            },
                            child: const Icon(CupertinoIcons.trash,
                                color: Colors.white, size: 25.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.19,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.07),
                        child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              var mediaItem = state.medias[index];
                              return EditingThumbsItemView(
                                image: mediaItem.videThumbPath != null && mediaItem.videThumbPath!.isNotEmpty
                                    ? mediaItem.videThumbPath!
                                    : mediaItem.filePath!,
                                isSelected: selectedMedia == mediaItem,
                                imageType: mediaItem.mediaType == MediaType.localVideo ||
                                        mediaItem.mediaType == MediaType.localImage
                                    ? ImageType.local
                                    : ImageType.remote,
                                durationInSeconds: mediaItem.durationInSeconds,
                                onTap: () {
                                  context.read<MediaEditingCubit>().selectMedia(mediaItem);
                                },
                              );
                            },
                            itemCount: state.medias.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                width: 5.0,
                              );
                            }),
                      ),
                    ),
                  ),
                  state.currentEditingText != null
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height * 0.05,
                              child: EditTextBar(
                                editingCubit: _editingCubit,
                              )),
                        )
                      : Align(
                          alignment: Alignment.bottomRight,
                          child: ShareBtn(
                            onTap: () async {
                              showLoadingDialogGif(context: context, dismiss: false);
                               await context.read<MediaEditingCubit>().processMedia();
                            },
                            isEdit: _editingCubit.setupCubit.state.initMediaData != null,
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
