import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg_media_editor/models/sound_model.dart';

import '../enums/enums.dart';

class MediaModel {
  String? filePath;
  String? text;
  List<TextInfo> texts = [];
  ColorFilterWithName color = ColorFilterWithName.transparent;
  double colorOpacity = 0.5;
  List<EmojiInfo> emojis = [];
  int? durationInSeconds;
  bool? isEditingFinished = false;
  bool skipProcessing = false;
  String id;
  late MediaType mediaType;
  VoidCallback? videoListener;
  bool videListened;
  bool isVideoInit;
  bool picked;
  String? videThumbPath;
  String? soundUrl;
  SoundModel? sound;
  double? mediaH;
  double? mediaW;
  bool? isSpeedMerged;
  bool? isFront;
  Transpose transpose = Transpose.none;
  double rotationAngle = 0.0;
  int rotationDegree = 0;
  bool isEdited = false;
  bool? isNew;
  Duration? pausedAt;
  int editedCount = max(0, 0);
  String? short;
  bool isCropped = false;

  MediaModel(
      {this.filePath,
      this.text,
      this.short,
      this.durationInSeconds = 0,
      this.isEditingFinished,
      required this.id,
      required this.mediaType,
      this.picked = false,
      this.isFront = false,
      this.soundUrl,
      this.isVideoInit = false,
      this.videThumbPath,
      this.videListened = false,
      this.videoListener,
      this.mediaH,
      this.mediaW,
      this.isSpeedMerged,
      this.isEdited = false,
      this.isNew = false});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MediaModel) return false;
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class EmojiInfo {
  String? image;
  double? x;
  double? y;
  double? xPer;
  double? yPer;
  double width;
  double height;
  bool isEmoji;
  bool isGif;
  ImageType imageType;

  EmojiInfo(
      {this.image,
      this.x,
      this.y,
      this.width = 100,
      this.height = 100,
      this.isEmoji = true,
      this.isGif = true,
      this.imageType = ImageType.remote,
      this.xPer,
      this.yPer});
}

class TextInfo {
  String text;
  double x;
  double y;
  double xPer;
  double yPer;
  Color color;
  String colorName;
  FontWeight fontWeight;
  FontStyle fontStyle;
  double fontSize;
  TextAlign textAlign;
  bool isLongPressed;
  String? fontFamily;

  TextInfo({
    required this.text,
    required this.x,
    required this.y,
    required this.xPer,
    required this.yPer,
    this.color = Colors.black,
    required this.fontWeight,
    required this.fontStyle,
    this.fontSize = 14,
    required this.textAlign,
    required this.isLongPressed,
    this.colorName = 'black',
    this.fontFamily,
  });
}

class MediaProcessInfo {
  final bool isEdited;
  final bool isNew;
  String path;
  final String mediaId;
  MediaType mediaType;
  String? videoThumbnail;
  final bool picked;
  String? short;
  Duration? pausedAt; //UI
  bool isBuffering = false; //UI
  double? mediaH;
  double? mediaW;
  int? durationInSeconds;

  MediaProcessInfo(
      {this.isEdited = false,
      this.isNew = false,
      required this.path,
      required this.mediaId,
      this.picked = false,
      required this.mediaType,
      this.videoThumbnail,
      this.short,
      this.mediaH,
      this.mediaW,
      this.durationInSeconds});

  MediaProcessInfo.fromJson(Map<String, dynamic> json)
      : isEdited = json['isEdited'] ?? false,
        isNew = json['isNew'] ?? false,
        path = json['path'] ?? '',
        mediaId = json['mediaId'] ?? '',
        mediaType = MediaType.values[json['mediaType'] ?? 0],
        videoThumbnail = json['videoThumbnail'],
        short = json['short'],
        mediaH = json['mediaH'],
        picked = json['picked'] ?? false,
        mediaW = json['mediaW'],
        durationInSeconds = json['durationInSeconds'];

  Map<String, dynamic> toJson({bool isCreate = true}) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['isEdited'] = isCreate ? false : isEdited;
    data['isNew'] = isNew;
    data['path'] = path;
    data['mediaId'] = mediaId;
    data['mediaType'] = mediaType.id;
    data['picked'] = picked;
    if (videoThumbnail != null && videoThumbnail!.isNotEmpty) {
      data['videoThumbnail'] = videoThumbnail;
    }
    if (short != null && short!.isNotEmpty) {
      data['short'] = short;
    }
    if (mediaH != null) {
      data['mediaH'] = mediaH;
    }
    if (mediaW != null) {
      data['mediaW'] = mediaW;
    }
    if (durationInSeconds != null) {
      data['durationInSeconds'] = durationInSeconds;
    }
    return data;
  }

  @override
  String toString() {
    return 'MediaSharedInfo{isEdited: $isEdited, isNew: $isNew, picked: $picked path: $path, mediaId: $mediaId} mediaType: ${mediaType.name} thumbnail: ${videoThumbnail.toString()} short: $short mediaH: $mediaH mediaW: $mediaW durationInSeconds: $durationInSeconds';
  }
}

class EmojiModel {
  final String id;
  final String image;
  final String? name;
  final bool isGif;

  EmojiModel({
    required this.id,
    required this.image,
    required this.name,
    this.isGif = false,
  });

  factory EmojiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmojiModel(
        id: json['id'] ?? Random().nextInt(1000000000).toString(),
        image: json['image'],
        name: json['name'],
        isGif: json['gif'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image': image, 'name': name, 'gif': isGif};
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is EmojiModel) {
      return id == other.id;
    }
    return false;
  }
}
