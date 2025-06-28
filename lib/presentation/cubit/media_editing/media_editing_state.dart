part of 'media_editing_cubit.dart';

enum MediaEditingStatus {
  initial,
  loading,
  error,
  success,
  mediaSelected,
  pickImageError,
  pickImageSuccess,
  toggleVideoWidget,
  selectText,
  cancelTextEditing,
  longPressItem,
  removeText,
  removeEmoji,
  addNewItem,
  changeEmojiSize,
  clearAllTextsLongPress,
  editText,
  addFilteredColor,
  changeOpacity,
  removeMediaItem,
  clearAllEmojisLongPress,
  cropImage,
  rotateImage,
}

class MediaEditingState extends Equatable {
  final MediaEditingStatus status;
  final MediaModel? selectedMedia;
  final List<MediaModel> medias;
  final bool showVideoWidget;
  final EmojiInfo? pressedEmoji;
  final TextInfo? currentEditingText;
  final Size? shaderSize;
  final double? devicePixels;
  final String? error;
  final List<MediaProcessInfo>? processedMedia;
  final bool saveToGallery;

  const MediaEditingState({
    this.status = MediaEditingStatus.initial,
    this.selectedMedia,
    this.medias = const [],
    this.showVideoWidget = true,
    this.pressedEmoji,
    this.currentEditingText,
    this.shaderSize,
    this.devicePixels,
    this.error,
    this.processedMedia,
    this.saveToGallery = false,
  });

  MediaEditingState copyWith({
    MediaEditingStatus? status,
    MediaModel? selectedMedia,
    List<MediaModel>? medias,
    bool? showVideoWidget,
    EmojiInfo? pressedEmoji,
    TextInfo? currentEditingText,
    Size? shaderSize,
    double? devicePixels,
    String? error,
    List<MediaProcessInfo>? processedMedia,
    bool? saveToGallery,
  }) {
    return MediaEditingState(
      status: status ?? this.status,
      selectedMedia: selectedMedia ?? this.selectedMedia,
      medias: medias ?? this.medias,
      showVideoWidget: showVideoWidget ?? this.showVideoWidget,
      pressedEmoji: pressedEmoji ?? this.pressedEmoji,
      currentEditingText: currentEditingText ?? this.currentEditingText,
      shaderSize: shaderSize ?? this.shaderSize,
      devicePixels: devicePixels ?? this.devicePixels,
      error: error ?? this.error,
      processedMedia: processedMedia ?? this.processedMedia,
      saveToGallery: saveToGallery ?? this.saveToGallery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedMedia,
    medias,
    showVideoWidget,
    pressedEmoji,
    currentEditingText,
    shaderSize,
    devicePixels,
    error,
    processedMedia,
    saveToGallery,
  ];
}
