import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg_media_editor/utilities/utils.dart';
import 'package:path_provider/path_provider.dart';

import '../enums/enums.dart';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';

import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import '../models/media_model.dart';
import 'package:image/image.dart' as img;

enum FfmpegMediaTypes {
  video("mp4"),
  image("jpg");

  final String savedExtension;

  const FfmpegMediaTypes(this.savedExtension);
}

class FfmpegFuncs {
  static Future<String> removeMirrorEffect(
      {required String mediaPath, required FfmpegMediaTypes type}) async {
    try {
      var directory = await getApplicationDocumentsDirectory();
      String directoryPath = "${directory.path}/processed";
      bool isDirectoryCreated = await Directory(directoryPath).exists();
      if (!isDirectoryCreated) {
        var directory = await Directory(directoryPath).create();
        printDebug("DIRECTORY CREATED AT : ${directory.path}");
      }
      final savedFileLocation =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.${type.savedExtension}';
      String command = '';
      if (type == FfmpegMediaTypes.image) {
        command =
            '-i $mediaPath \-filter:v "hflip"\ -c:a copy $savedFileLocation';
      } else {
        // video
        command = '-i $mediaPath -vf hflip -qscale:v 2 $savedFileLocation';
      }

      var session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        printDebug('SUCCESS disableMirrorByFFMPEG');
        return savedFileLocation;
      } else if (ReturnCode.isCancel(returnCode)) {
        printDebug('CANCEL disableMirrorByFFMPEG');
        return '';
      } else {
        printDebug('ERROR disableMirrorByFFMPEG');
        return '';
      }
    } catch (e) {
      printDebug('ERROR disableMirrorByFFMPEG: $e');
      return '';
    }
  }

  static Future<String> mergeSoundWithMedia(
      {required String mediaPath,
      required String audioPath,
      required FfmpegMediaTypes type}) async {
    try {
      var directory = await getApplicationDocumentsDirectory();
      String directoryPath = "${directory.path}/processed";
      bool isDirectoryCreated = await Directory(directoryPath).exists();
      if (!isDirectoryCreated) {
        var directory = await Directory(directoryPath).create();
        printDebug("DIRECTORY CREATED AT : ${directory.path}");
      }
      final savedFileLocation =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

      printDebug('mediaPath: $mediaPath , audioPath: $audioPath');
      String command = '';
      if (type == FfmpegMediaTypes.video) {
        command =
            "-i $mediaPath -stream_loop -1 -i $audioPath -shortest -map 0:v:0 -map 1:a:0 -qscale:v 2 $savedFileLocation";
      } else {
        bool isFitted = await checkImageFit(imagePath: mediaPath);
        if (!isFitted) {
          String fittedImage = await fitImage(imagePath: mediaPath);
          if (fittedImage.isNotEmpty) {
            mediaPath = fittedImage;
          }
        }
        command =
            '-i $mediaPath -i $audioPath -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -filter_complex "[1:a]atrim=0:60,asetpts=PTS-STARTPTS[audio];[0:v][audio]concat=n=1:v=1:a=1[v][a]" -map "[v]" -map "[a]" -shortest $savedFileLocation';
      }

      var session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        printDebug('SUCCESS process Audio: $savedFileLocation');
        return savedFileLocation;
      } else if (ReturnCode.isCancel(returnCode)) {
        printDebug('CANCEL process Audio');
        return '';
      } else {
        printDebug(
            'ERROR process Audio: Please remain your audio with valid format before select it'); //TODO: show toast
        return '';
      }
    } catch (e) {
      printDebug('ERROR mergeSoundWithVideo: $e');
      return '';
    }
  }

  static Future<bool> checkFileExist(String filePath) async {
    try {
      final file = File(filePath);
      final directory = Directory(filePath);

      if (!await file.exists() && !await directory.exists()) {
        printDebug('File or directory does not exist');
        return false;
      }
      return true;
    } catch (e) {
      printDebug('ERROR checkFileExist: $e');
      return false;
    }
  }

  static Future<bool> checkImageFit({required String imagePath}) async {
    try {
      var directory = await getApplicationDocumentsDirectory();
      String directoryPath = "${directory.path}/processed";
      bool isDirectoryCreated = await Directory(directoryPath).exists();
      if (!isDirectoryCreated) {
        var directory = await Directory(directoryPath).create();
        printDebug("DIRECTORY CREATED AT : ${directory.path}");
      }
      final savedFileLocation =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
      String command =
          '-i $imagePath -vf "scale=iw*min(1280/iw\\,720/ih):ih*min(1280/iw\\,720/ih), pad=1280:720:(1280-iw*min(1280/iw\\,720/ih))/2:(720-ih*min(1280/iw\\,720/ih))/2:black" $savedFileLocation';
      var session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        printDebug('SUCCESS checkImageFit: $savedFileLocation');
        final originalImage =
            img.decodeImage(File(imagePath).readAsBytesSync())!;
        final processedImage =
            img.decodeImage(File(savedFileLocation).readAsBytesSync())!;
        return originalImage.width == processedImage.width &&
            originalImage.height == processedImage.height;
      } else if (ReturnCode.isCancel(returnCode)) {
        printDebug('CANCEL checkImageFit');
        return false;
      } else {
        printDebug('ERROR checkImageFit');
        return false;
      }
    } catch (e) {
      printDebug('ERROR checkImageFit: $e');
      return false;
    }
  }

  static Future<String> fitImage({required String imagePath}) async {
    try {
      var directory = await getApplicationDocumentsDirectory();
      String directoryPath = "${directory.path}/p rocessed";
      bool isDirectoryCreated = await Directory(directoryPath).exists();
      if (!isDirectoryCreated) {
        var directory = await Directory(directoryPath).create();
        printDebug("DIRECTORY CREATED AT : ${directory.path}");
      }
      final savedFileLocation =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
      String command =
          '-i $imagePath -vf "scale=iw*min(1280/iw\\,720/ih):ih*min(1280/iw\\,720/ih), pad=1280:720:(1280-iw*min(1280/iw\\,720/ih))/2:(720-ih*min(1280/iw\\,720/ih))/2:black" $savedFileLocation';
      var session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        printDebug('SUCCESS checkImageFit: $savedFileLocation');
        return savedFileLocation;
      } else if (ReturnCode.isCancel(returnCode)) {
        printDebug('CANCEL checkImageFit');
        return '';
      } else {
        printDebug('ERROR checkImageFit');
        return '';
      }
    } catch (e) {
      printDebug('ERROR checkImageFit: $e');
      return '';
    }
  }

  static Future<String> mergeVideoSpeed(
      {required String videoPath, required double speed}) async {
    try {
      var directory = await getApplicationDocumentsDirectory();
      String directoryPath = "${directory.path}/processed";
      bool isDirectoryCreated = await Directory(directoryPath).exists();
      if (!isDirectoryCreated) {
        var directory = await Directory(directoryPath).create();
        printDebug("DIRECTORY CREATED AT : ${directory.path}");
      }
      final savedFileLocation =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.mp4';
      String command =
          '-i $videoPath -filter_complex "[0:v]setpts=PTS/$speed[v];[0:a]atempo=$speed[a]" -map "[v]" -map "[a]" -qscale:v 2 $savedFileLocation'; //Looping audio
      var session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        printDebug('SUCCESS Video Speed');
        return savedFileLocation;
      } else if (ReturnCode.isCancel(returnCode)) {
        printDebug('CANCEL process');
        return '';
      } else {
        printDebug('ERROR process');
        return '';
      }
    } catch (e) {
      printDebug('ERROR mergeVideoSpeed: $e');
      return '';
    }
  }

  int emojiIndex = 0;

  static Future<String> overLayEmoji({
    required String path,
    required List<EmojiInfo> emojis,
    required num width,
    required num height,
    required FfmpegMediaTypes mediaPathType,
    required bool cameraMedia,
  }) async {
    try {
      String inputEmojis = '';
      String emojiScale = '';
      String emojiOverlay = '';
      int emojiIndex = 0;
      await Future.forEach(emojis, (EmojiInfo emoji) async {
        double? ex;
        double? ey;
        double? ew;
        double? eh;

        ex = emoji.x ?? 100.0;
        ey = emoji.y ?? 100.0;
        ew = cameraMedia ? emoji.width : emoji.width + (emoji.width * 0.2);
        eh = cameraMedia ? emoji.height : emoji.height + (emoji.height * 0.2);

        //If emoji is local we have to get the file first
        File? imageFile;
        if (emoji.imageType == ImageType.remote) {
          final imageBytes = await getFileBytesFromUrl(emoji.image!);
          imageFile = await getMediaFileFromBytes(
            mediaBytes: imageBytes,
            mediaUrl: emoji.image!,
          );
        } else {
          imageFile = File(emoji.image!);
        }

        if (imageFile == null) return;
        //GIF requires "ignore_loop 0" before each input to make GIF looping inside video
        //without it gif will only work for one time and stop
        inputEmojis = emoji.isGif
            ? "$inputEmojis -ignore_loop 0 -i ${imageFile.path}"
            : "$inputEmojis -i ${imageFile.path}";
        emojiScale +=
            "[${emojiIndex + 1}:v]scale=$ew:$eh[ovrl${emojiIndex + 1}];";

        //we have to separate between each overlay by ";", but the final one has
        //to be empty space .. without this condition it will not work
        String comma = emojis.length > 1
            ? emojiIndex == emojis.length - 1
                ? ' '
                : ';'
            : ' ';
        //[0:v][ovrl1] means that ovrl1 will be on top of input 0 which is the recorded video
        String mainBG = emojiIndex == 0 ? '[ovrl0]' : '[bg$emojiIndex]';
        String finalBG =
            emojiIndex == emojis.length - 1 ? '[out]' : '[bg${emojiIndex + 1}]';

        if (cameraMedia) {
          emojiOverlay = emoji.isGif
              ? "$emojiOverlay$mainBG[ovrl${emojiIndex + 1}]overlay=$ex:$ey:shortest=1$finalBG$comma"
              : "$emojiOverlay$mainBG[ovrl${emojiIndex + 1}]overlay=$ex:$ey$finalBG$comma";
        } else {
          emojiOverlay = emoji.isGif
              ? "$emojiOverlay$mainBG[ovrl${emojiIndex + 1}]overlay=w*${emoji.xPer}:h*${emoji.yPer}:shortest=1$finalBG$comma"
              : "$emojiOverlay$mainBG[ovrl${emojiIndex + 1}]overlay=w*${emoji.xPer}:h*${emoji.yPer}$finalBG$comma";
        }

        emojiIndex++;
      });
      var directory = await getApplicationDocumentsDirectory();
      String directoryPath = "${directory.path}/processed";
      bool isDirectoryCreated = await Directory(directoryPath).exists();
      if (!isDirectoryCreated) {
        var directory = await Directory(directoryPath).create();
        printDebug("DIRECTORY CREATED AT : ${directory.path}");
      }
      final savedFileLocation =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

      printDebug('outputVideoPathWithEmoji: $savedFileLocation ');

      int outputWidth = width.toInt();
      int outputHeight = height.toInt();

      if (cameraMedia) {
        // Check if the dimensions are within acceptable range
        if (outputWidth <= 0 || outputHeight <= 0) {
          printDebug(
              'Invalid dimensions: width=$outputWidth, height=$outputHeight');
          return ''; // or handle the error accordingly
        }
        // Ensure that the dimensions are divisible by 2 (required by some codecs)
        outputWidth = (outputWidth ~/ 2) * 2;
        outputHeight = (outputHeight ~/ 2) * 2;
      }
      /*else{
        outputWidth = 512;
        outputHeight = 512;
      }*/

      String commandToExecute = '';

      printDebug('outputWidth: $outputWidth outputHeight: $outputHeight');
      // Use the validated dimensions in the FFmpeg command
      if (cameraMedia) {
        commandToExecute = '-i $path$inputEmojis '
            '-filter_complex "[0:v]scale=$outputWidth:$outputHeight[ovrl0]; $emojiScale $emojiOverlay" '
            '-map [out] -map 0:a:? -c:v libx264 -b:v 2M -r 30 -c:a aac -shortest $savedFileLocation';
      } else {
        commandToExecute = '-i $path$inputEmojis '
            '-filter_complex "[0:v]scale=trunc(iw/2)*2:trunc(ih/2)*2[ovrl0]; $emojiScale $emojiOverlay" '
            '-map [out] -map 0:a:? -c:v libx264 -b:v 2M -r 30 -c:a aac -shortest $savedFileLocation';
      }

      printDebug('emojiCommand: $commandToExecute');

      var session = await FFmpegKit.execute(commandToExecute);
      final emojiReturnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(emojiReturnCode)) {
        printDebug('SUCCESS emoji');
        return savedFileLocation;
      } else if (ReturnCode.isCancel(emojiReturnCode)) {
        printDebug('CANCEL emoji');
        return '';
      } else {
        printDebug('ERROR emoji');
        return '';
      }
    } catch (e) {
      printDebug('ERROR overLayEmoji: $e');
      return '';
    }
  }

  static Future<String> resizeVideo(
      {required String inputPath,
      required int newWidth,
      required int newHeight}) async {
    var directory = await getApplicationDocumentsDirectory();
    String directoryPath = "${directory.path}/processed";
    bool isDirectoryCreated = await Directory(directoryPath).exists();
    if (!isDirectoryCreated) {
      var directory = await Directory(directoryPath).create();
      printDebug("DIRECTORY CREATED AT : ${directory.path}");
    }
    final savedFileLocation =
        '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

    final arguments = [
      '-i',
      inputPath,
      '-vf',
      'scale=$newWidth:$newHeight',
      savedFileLocation,
    ];

    printDebug('resizeVideo: $arguments');

    var session = await FFmpegKit.executeWithArguments(arguments);
    final resizeReturnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(resizeReturnCode)) {
      printDebug('SUCCESS resize');
      return savedFileLocation;
    } else if (ReturnCode.isCancel(resizeReturnCode)) {
      printDebug('CANCEL resize');
      return '';
    } else {
      printDebug('ERROR resize');
      return '';
    }
  }

  //useless
  static Future<String> overlayImageOnVideo({
    required String inputVideoPath,
    required EmojiInfo emojiInfo,
    required String inputImagePath,
  }) async {
    File? imageFile;
    final imageBytes = await getFileBytesFromUrl(inputImagePath);
    imageFile = await getMediaFileFromBytes(
      mediaBytes: imageBytes,
      mediaUrl: inputImagePath,
    );

    var directory = await getApplicationDocumentsDirectory();
    String directoryPath = "${directory.path}/processed";
    bool isDirectoryCreated = await Directory(directoryPath).exists();
    if (!isDirectoryCreated) {
      var directory = await Directory(directoryPath).create();
      printDebug("DIRECTORY CREATED AT : ${directory.path}");
    }
    final savedFileLocation =
        '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

    // FFmpeg command to overlay image on video
    final List<String> command = [
      '-i',
      inputVideoPath,
      '-i',
      imageFile!.path,
      '-filter_complex',
      //  'overlay=W-w-${emojiInfo.xPer}:H-h-${emojiInfo.yPer}', // Adjust overlay position if needed
      //'overlay=x=(W-w)*${emojiInfo.xPer}:y=(H-h)*${emojiInfo.yPer}',
      // '[0:v][1:v] overlay=x=${emojiInfo.x}:y=${emojiInfo.y}',
      'overlay=x=${emojiInfo.x}:y=${emojiInfo.y}',

      '-c:v',
      'libx264',
      '-preset',
      'ultrafast',
      // Video encoding preset
      '-c:a',
      'aac',
      savedFileLocation,
    ];


    // Execute the FFmpeg command
    var session = await FFmpegKit.executeWithArguments(command);
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      // SUCCESS
      printDebug('SUCCESS overlayImageOnVideo');
      return savedFileLocation;
    } else if (ReturnCode.isCancel(returnCode)) {
      printDebug('CANCEL overlayImageOnVideo');
      return '';
    } else {
      printDebug('ERROR overlayImageOnVideo');
      return '';
    }
  }

 static Future<File?> getVideoThumbnail(String videoPath) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String thumbnailPath = '${tempDir.path}/thumb.jpg';

      // Extract a frame at 1 second (you can change the time)
      final String command = "-i \"$videoPath\" -ss 00:00:01 -vframes 1 \"$thumbnailPath\"";

      await FFmpegKit.execute(command);

      return File(thumbnailPath);
    } catch (e) {
      printDebug("Error generating thumbnail: $e");
      return null;
    }
  }
  static Future<double> getFileDuration(String mediaPath) async {
    final mediaInfoSession = await FFprobeKit.getMediaInformation(mediaPath);
    final mediaInfo = mediaInfoSession.getMediaInformation()!;

    // the given duration is in fractional seconds
    final duration = double.parse(mediaInfo.getDuration()!);
    return duration;
  }

  static Future<String> overlayImage(
      {required String mediaPath,
      required Size shaderSize,
      required EmojiInfo emoji,
      required FfmpegMediaTypes mediaPathType}) async {
    final directory = await getApplicationDocumentsDirectory();
    final directoryPath = "${directory.path}/processed";
    final isDirectoryCreated = await Directory(directoryPath).exists();

    if (!isDirectoryCreated) {
      await Directory(directoryPath).create(recursive: true);
      printDebug('DIRECTORY CREATED AT: $directoryPath');
    }

    final savedFileLocation = mediaPathType == FfmpegMediaTypes.video
        ? '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.mp4'
        : '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.gif';

    File? overlayImageFile;

    if (mediaPathType == FfmpegMediaTypes.video || emoji.isGif) {
      final imageBytes = await getFileBytesFromUrl(emoji.image!);
      overlayImageFile = await getMediaFileFromBytes(
        mediaBytes: imageBytes,
        mediaUrl: emoji.image!,
      );

      if (overlayImageFile == null) {
        printDebug('Failed to get overlay image file');
        return '';
      }
    }

    String command;

    if (mediaPathType == FfmpegMediaTypes.video) {
      if (emoji.isGif) {
        command =
            '-loop 1 -i $mediaPath -ignore_loop 0 -i ${overlayImageFile!.path} -filter_complex "[0:v]setpts=PTS-STARTPTS[v0];[1:v]scale=${emoji.width}:${emoji.height},setpts=PTS-STARTPTS+${2}/TB[v1];[v0][v1]overlay=${emoji.x}:${emoji.y}:enable=\'between(t,0,${2})\'" -map "[v0]" -map 0:a? -c:v libx264 -c:a copy $savedFileLocation';
      } else {
        command =
            '-i $mediaPath -i ${overlayImageFile!.path} -filter_complex "[1:v]scale=${emoji.width}:${emoji.height}[ovrl];[0:v][ovrl]overlay=${emoji.x}:${emoji.y}" -map 0:a? -c:v libx264 -c:a copy $savedFileLocation';
      }
    } else {
      if (emoji.isGif) {
        command =
            '-loop 1 -i $mediaPath -ignore_loop 0 -i ${overlayImageFile!.path} -filter_complex "[0:v]setpts=PTS-STARTPTS[v0];[1:v]scale=${emoji.width}:${emoji.height},setpts=PTS-STARTPTS+${2}/TB[v1];[v0][v1]overlay=${emoji.x}:${emoji.y}:enable=\'between(t,0,${2})\'" $savedFileLocation';
      } else {
        command =
            '-i $mediaPath -i ${overlayImageFile!.path} -filter_complex "[1:v]scale=${emoji.width}:${emoji.height}[ovrl];[0:v][ovrl]overlay=${emoji.x}:${emoji.y}" $savedFileLocation';
      }
    }

    final session = await FFmpegKit.executeAsync(command);
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      printDebug('emjiSuccess');
      return savedFileLocation;
    } else if (ReturnCode.isCancel(returnCode)) {
      printDebug('emojiCancel');
      return '';
    } else {
      printDebug('emojiError');
      return '';
    }
  }

  static Future<String> overLayText(
      {required String path,
      required List<TextInfo> texts,
      required bool isVideo,
      required double h,
      required double w}) async {
    try {
      var tempDir = await getTemporaryDirectory();
      String outputVideoPathWithText =
          '${tempDir.path}/${getRandomString(5)}.${isVideo ? 'mp4' : 'jpg'}';

      const String filename = 'cairo.ttf';

      ByteData data = await rootBundle.load("assets/fonts/Cairo-SemiBold.ttf");
      final fontPath = '${tempDir.path}/$filename';
      final buffer = data.buffer;
      await File(fontPath).writeAsBytes(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      File file = File('$tempDir/$filename');
      printDebug('Loaded file ${file.path}');

      await FFmpegKitConfig.setFontDirectoryList(
          ["/system/fonts", "/System/Library/Fonts", file.path]);

      String textExec = '';

      //texts for loop
      for (int i = 0; i < texts.length; i++) {
        printDebug(
            'textSize: ${texts[i].fontSize} xIs: ${texts[i].x} yIs: ${texts[i].y} wIs: $w hIs: $h');
        textExec =
            '$textExec${i != 0 ? ',' : ''}drawtext=text=${"'${texts[i].text}'"}:x=w*${texts[i].xPer}:y=h*${texts[i].yPer}:fontcolor=${texts[i].colorName}:fontfile=${"'/data/user/0/com.q8intouch.hareem.new/cache'/$filename"}:fontsize=${texts[i].fontSize * 2}';
      }
      printDebug('textExec: $textExec');

      String commentToEx =
          '-i $path -vf "$textExec" -qscale:v 2 -c:a copy $outputVideoPathWithText';

      var textSession = await FFmpegKit.execute(commentToEx);
      printDebug('commentToEx: $commentToEx');
      final textReturnCode = await textSession.getReturnCode();
      printDebug('code: $textReturnCode');
      if (ReturnCode.isSuccess(textReturnCode)) {
        printDebug('successText: $outputVideoPathWithText');
        return outputVideoPathWithText;
      } else if (ReturnCode.isCancel(textReturnCode)) {
        printDebug('textCancel');
        return '';
      } else {
        printDebug('textError');
        return '';
      }
    } catch (e) {
      printDebug('textError: $e');
      return '';
    }
  }

  static Future<String> splitVideo({required String path, int secs = 5}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final directoryPath = "${directory.path}/processed";
      final isDirectoryCreated = await Directory(directoryPath).exists();

      if (!isDirectoryCreated) {
        await Directory(directoryPath).create(recursive: true);
        printDebug('DIRECTORY CREATED AT: $directoryPath');
      }

      final savedFileLocation =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

      String ffmpegCommand = "-i $path -c copy -t $secs $savedFileLocation";

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        printDebug('splitSuccess');
        return savedFileLocation;
      } else if (ReturnCode.isCancel(returnCode)) {
        printDebug('splitCancel');
        return '';
      } else {
        printDebug('splitError');
        return '';
      }
    } catch (e) {
      printDebug('splitError: $e');
      return '';
    }
  }

  static Future<String> convertVideoToGif(
      {required String path, int secs = 5}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final directoryPath = "${directory.path}/processed";
      final isDirectoryCreated = await Directory(directoryPath).exists();

      if (!isDirectoryCreated) {
        await Directory(directoryPath).create(recursive: true);
        printDebug('DIRECTORY CREATED AT: $directoryPath');
      }

      final savedFileLocation =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.gif';

      String ffmpegCommand =
          "-i $path -t $secs -vf \"fps=30,scale=320:-1:flags=lanczos\" -c:v gif $savedFileLocation";

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        printDebug('convertVideoToGifSuccess');
        return savedFileLocation;
      } else if (ReturnCode.isCancel(returnCode)) {
        printDebug('convertVideoToGifCancel');
        return '';
      } else {
        printDebug('convertVideoToGifError');
        return '';
      }
    } catch (e) {
      printDebug('convertVideoToGiftError: $e');
      return '';
    }
  }

  static Future<String> overLayColorOverMedia(
      {required String path,
      required ColorFilterWithName color,
      required double colorOpacity,
      required FfmpegMediaTypes type,
      required double w,
      required double h}) async {
    try {
      if (color.name == 'transparent') {
        return path;
      }
      var tempDir = await getTemporaryDirectory();
      String outputVideoPathWithColor =
          '${tempDir.path}/${getRandomString(5)}.${type == FfmpegMediaTypes.video ? 'mp4' : 'jpg'}';

      double opacity = colorOpacity * 0.7;

      String colorExecute;
      if (color.name != 'black') {
        if (type != FfmpegMediaTypes.video) {
          debugPrint('colorImage');
          File image = File(path);
          var decodedImage = await decodeImageFromList(image.readAsBytesSync());
          if (color.name == 'white') {
            colorExecute =
                '-i $path -f lavfi -i "color=white@0.5:s=${w.toInt()}x${h.toInt()}:c=white" -filter_complex "[0:v]setsar=sar=1/1[s];[s][1:v]blend=shortest=1:all_mode=normal:all_opacity=0.7[out]" -map [out] -map 0:a:? -qscale:v 2 $outputVideoPathWithColor';
          } else {
            colorExecute =
                '-i $path -f lavfi -i "color=${color.name}:s=${decodedImage.width}x${decodedImage.height}" \-filter_complex "[0:v]setsar=sar=1/1[s];\[s][1:v]blend=shortest=1:all_mode=reflect:all_opacity=$opacity[out]" \-map [out] -map 0:a:? -qscale:v 2 $outputVideoPathWithColor';
          }
        } else {
          if (color.name == 'white') {
            colorExecute =
                '-i $path -f lavfi -i "color=white@0.5:s=${w.toInt()}x${h.toInt()}:c=white" -filter_complex "[0:v]setsar=sar=1/1[s];[s][1:v]blend=shortest=1:all_mode=normal:all_opacity=0.7[out]" -map [out] -map 0:a:? -qscale:v 2 $outputVideoPathWithColor';
          } else {
            colorExecute =
                '-i $path -f lavfi -i "color=${color.name}:s=${w.toInt()}x${h.toInt()}" \-filter_complex "[0:v]setsar=sar=1/1[s];\[s][1:v]blend=shortest=1:all_mode=reflect:all_opacity=$opacity[out]" \-map [out] -map 0:a:? -qscale:v 2 $outputVideoPathWithColor';
          }
        }
      } else {
        //black and white
        colorExecute =
            '-i $path -vf hue=s=0 -qscale:v 2 $outputVideoPathWithColor';
      }

      printDebug('colorExecute: $colorExecute');
      var colorSession = await FFmpegKit.execute(colorExecute);
      final colorReturnCode = await colorSession.getReturnCode();
      printDebug('colorReturnCode: $colorReturnCode');
      if (ReturnCode.isSuccess(colorReturnCode)) {
        printDebug('successColor');
        return outputVideoPathWithColor;
      } else if (ReturnCode.isCancel(colorReturnCode)) {
        printDebug('colorCancel');
        return '';
      } else {
        printDebug('colorError');
        return '';
      }
    } catch (e) {
      printDebug('colorErrorExp: $e');
      return '';
    }
  }

  static Future<String> rotateImage(
      {required String imagePath, required Transpose transpose}) async {
    try {
      var tempDir = await getTemporaryDirectory();
      String outputVideoPathWithColor =
          '${tempDir.path}/${getRandomString(5)}.jpg';

      String command =
          '-i $imagePath -vf "${transpose.stringVal}" $outputVideoPathWithColor';

      //'-i $imagePath -vf transpose=2 $outputVideoPathWithColor'
      printDebug('rotateImage: $command');

      var session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        printDebug('rotateImageSuccess');
        return outputVideoPathWithColor;
      } else if (ReturnCode.isCancel(returnCode)) {
        printDebug('rotateImageCancel');
        return '';
      } else {
        printDebug('rotateImageError');
        return '';
      }
    } catch (e) {
      printDebug('rotateImageError: $e');
      return '';
    }
  }

  static Future<String> convertImageToVideo(
      {required String imagePath,
      required num height,
      required num width}) async {
    try {
      var tempDir = await getTemporaryDirectory();
      String outputVideoPath = '${tempDir.path}/${getRandomString(5)}.mp4';

      final command =
          '-loop 1 -i $imagePath -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -t 5 $outputVideoPath';
      var session = await FFmpegKit.execute(command);
      printDebug('commentToEx: $command');

      final textReturnCode = await session.getReturnCode();
      printDebug('code: $textReturnCode');
      if (ReturnCode.isSuccess(textReturnCode)) {
        printDebug('successConvertImageToVideo');
        return outputVideoPath;
      } else if (ReturnCode.isCancel(textReturnCode)) {
        printDebug('cancelConvertImageToVideo');
        return '';
      } else {
        printDebug('errorConvertImageToVideo');
        return '';
      }
    } catch (e) {
      printDebug('errorConvertImageToVideo: $e');
      return '';
    }
  }
}
