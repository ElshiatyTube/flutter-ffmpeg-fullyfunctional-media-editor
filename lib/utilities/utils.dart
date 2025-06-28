import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/cubit/camera/camera_cubit.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/cubit/setup/setup_cubit.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/cubit/sound/sound_cubit.dart';
import 'package:flutter_ffmpeg_media_editor/presentation/screen/main_screen.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:http/http.dart' as http;

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image_cropper/image_cropper.dart';

import '../enums/enums.dart';

Future<Uint8List> getFileBytesFromUrl(String url) async {
  var response = await http.get(Uri.parse(url));
  return response.bodyBytes;
}

void printDebug(String message) {
  if (kDebugMode) {
    print(message);
  }
}

Widget defaultCircularProgressIndicator(
    {double? width, double? height, Color? color}) {
  return SizedBox(
      width: width,
      height: height,
      child: Center(
          child: CircularProgressIndicator(
            color: color,
          )));
}
String getRandomString(int length) {
  String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}
Future<File?> getMediaFileFromBytes(
    {required Uint8List mediaBytes, required String mediaUrl}) async {
  try {
    printDebug('mediaBytes: $mediaBytes mediaUrl: $mediaUrl');
    final tempDir = await getTemporaryDirectory();
    final String imageName = path.basename(mediaUrl);
    final file = File(path.join(tempDir.path, imageName));
    file.writeAsBytesSync(mediaBytes);
    return file;
  } catch (e) {
    return null;
  }
}
Future<String> renameFilePath(
    {required String filePath, required String dirName}) async {
  var directory = await getApplicationDocumentsDirectory();
  String directoryPath = "${directory.path}/$dirName";
  bool isDirectoryCreated = await Directory(directoryPath).exists();
  if (!isDirectoryCreated) {
    var directory = await Directory(directoryPath).create();
    printDebug("DIRECTORY CREATED AT : ${directory.path}");
  }
  final file = File(filePath);
  final fileName = file.path.split('/').last;
  final fileExtension = fileName.split('.').last;
  final newFilePath =
      '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
  file.renameSync(newFilePath);
  return newFilePath;
}
extension StringExtensions on String {
  bool endsWithAny(List<String> suffixes) {
    for (var suffix in suffixes) {
      if (endsWith(suffix)) {
        return true;
      }
    }
    return false;
  }
}

Future<String?> pickImageFromGalleryUtil(
    {FileType fileType = FileType.image,
      bool allowMultiple = false}) async {
  FilePickerResult? picked = await FilePicker.platform.pickFiles(
    type: fileType,
    allowedExtensions: allowedImageExtensions,
    allowMultiple: allowMultiple,
  );
  if (picked != null && picked.files.isNotEmpty) {
    String? filePath = picked.files.first.path;
    if (filePath != null) {
      return filePath;
    } else {
      printDebug('File path is null');
      return null;
    }
  } else {
    printDebug('No file selected');
    return null;
  }

}
Future<CroppedFile?> cropImageUtil(
    {required String imagePath}) async {
  return await ImageCropper().cropImage(
    sourcePath: imagePath,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.ratio3x2,
        ],
      ),
      IOSUiSettings(
        title: 'Cropper',
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.ratio3x2,
        ],
      )
    ],
  );
}
class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

Future<Size> getImageOrgSize(
    {required String imagePath, required MediaType type}) async {
  Completer<ui.Image> completer = Completer<ui.Image>();
  Image imageWidget = type == MediaType.remoteImage
      ? Image.network(imagePath)
      : Image.file(File(imagePath));

  imageWidget.image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
      if (!completer.isCompleted) {
        ui.Image uiImage = imageInfo.image;
        completer.complete(uiImage);
      }
    }),
  );
  // Wait for the completer to complete and retrieve the image dimensions
  ui.Image image = await completer.future;
  double w = image.width.toDouble(); // Width of the image in pixels
  double h = image.height.toDouble(); // Height of the image in pixels

  printDebug('Image width: $w pixels');
  printDebug('Image height: $h pixels');

  return Size(w, h);
}
const double defaultEmojiWidth = 130;
const double defaultEmojiHeight = 130;

Future<FilePickerResult?> pickFiles(
    {List<String>? allowedExtensions,
      FileType fileType = FileType.custom,
      bool allowMultiple = false}) {
  return FilePicker.platform.pickFiles(
    type: fileType,
    allowedExtensions: allowedExtensions,
    allowMultiple: allowMultiple,
  );
}
Future<bool?> saveNetworkImage(String image, {required bool isVideo}) async {
  try {
    return isVideo
        ? await GallerySaver.saveVideo(image)
        : await GallerySaver.saveImage(image);
  } catch (e) {
    return null;
  }
}
bool checkVideoType(MediaType type) {
  return type == MediaType.remoteVideo || type == MediaType.localVideo;
}

const List<String> allowedVideoExtensions = ['mp4'];
const List<String> allowedImageExtensions = ['jpg','jpeg','png'];
Future<List<num>> getVideoHeightAndWidthAndDuration(
    {required String url, required MediaType type}) async {
  final videoPlayerController = type == MediaType.remoteVideo
      ? VideoPlayerController.networkUrl(Uri.parse(url))
      : VideoPlayerController.file(File(url));
  await videoPlayerController.initialize();
  final videoHeight = videoPlayerController.value.size.height;
  final videoWidth = videoPlayerController.value.size.width;
  final duration = videoPlayerController.value.duration.inSeconds;
  videoPlayerController.dispose();
  return [videoHeight, videoWidth, duration];
}
void showLoadingDialogGif(
    {required BuildContext context, required bool dismiss, String? text}) {
  showGeneralDialog(
    context: context,
    pageBuilder: (_, __, ___) {
      return WillPopScope(
        onWillPop: () async {
          return dismiss;
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white, // Dialog background
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const CupertinoActivityIndicator(),
          ),
        ),
      );
    },
  );
}
String durationToString(int minutes) {
  var d = Duration(minutes: minutes);
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}
String currentVideoSecWithDurationToString(int currentSec, int totalSec) {
  List<String> parts = currentSec.toString().split(':');
  List<String> parts2 = totalSec.toString().split(':');
  return '${parts[0].padLeft(2, '0')}:${parts2[0].padLeft(2, '0')}';
}
String currentVideoSecToString(int currentSec) {
  int minutes = (currentSec / 60).floor();
  int seconds = currentSec % 60;
  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = seconds.toString().padLeft(2, '0');
  return '$minutesStr:$secondsStr';
}

Widget videoBuffering(BuildContext context) {
  return Center(
    child: SizedBox(
      height: 40,
      width: 40,
      child: CircularProgressIndicator(
        backgroundColor: Theme.of(context).primaryColor,
        strokeWidth: 0.7,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
  );
}

String formatVideoMinSec(int positionInSeconds) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  int minutes = (positionInSeconds / 60).floor();
  int seconds = positionInSeconds % 60;

  String formattedMinutes = minutes > 0 ? twoDigits(minutes) : '0';
  String formattedSeconds = twoDigits(seconds);

  return '$formattedMinutes:$formattedSeconds';
}
void showBasicAlertDialog(
    {required BuildContext context,
      required String message,
      required String title,
      VoidCallback? onCancelClick,
      required VoidCallback onConfirmClick,
      Color onConfirmColor = Colors.green,
      Color onCancelColor = Colors.black,
      required String onCancelBtnText,
      required String onConfirmBtnText,
      Widget? customButton,
      bool dismissible = true,
      required Widget icon}) {
  showDialog(
    context: context,
    barrierDismissible: dismissible,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        return dismissible;
      },
      child: AlertDialog(
        title: Row(
          children: [
            icon,
            const SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          onCancelClick != null
              ? TextButton(
            onPressed: onCancelClick,
            child: Text(
              onCancelBtnText,
              style: TextStyle(
                color: onCancelColor,
                fontWeight: FontWeight.bold,),
            ),
          )
              : Container(),
          const SizedBox(
            height: 10.0,
          ),
          TextButton(
            onPressed: onConfirmClick,
            child: Text(
              onConfirmBtnText,
              style: TextStyle(
                color: onConfirmColor,
                fontWeight: FontWeight.bold,),
            ),
          ),
          if(customButton!=null)...[
            const SizedBox(
              height: 10.0,
            ),
            customButton,
          ]

        ],
      ),
    ),
  );
}
Future<dynamic> showCustomBottomSheet({
  required BuildContext context,
  required Widget child,
}) async {
  dynamic value = await showModalBottomSheet(
    elevation: 20.0,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    context: context,
    builder: (context) {
      return child;
    },
  );
  return value;
}
//provide main screen
Widget ffmpegMediaEditor(BuildContext context) {
  return MultiBlocProvider(providers: [
    BlocProvider(
      create: (context) => CameraCubit(),
    ),
    BlocProvider(
      create: (context) => SetupCubit(),
    ),
    BlocProvider(
      create: (context) => SoundCubit(),
    ),
    // Add other cubits or providers here if needed
  ], child: MainScreen());
}
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
