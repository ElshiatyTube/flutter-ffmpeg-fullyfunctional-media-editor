# Flutter FFmpeg Media Editor

A powerful Flutter package for advanced media editing capabilities using FFmpeg. This package provides comprehensive tools for editing images and videos with features like text overlays, emoji/sticker placement, color filters, speed adjustments, and more.

## 🚀 Production Ready

This media editing module is actively used in production and powers the media editing features of **[Blogs Chat](https://play.google.com/store/apps/details?id=com.q8intouch.hareem.new)** - a popular social media app available on Google Play Store with over 10K+ downloads. The app enables users to create engaging content with live streaming, chat, reels, posts, and advanced media editing capabilities.

## 🎯 Features

### 📸 Image Editing
- **Text Overlays**: Add customizable text with various fonts, colors, sizes, and alignments
- **Emoji/Sticker Support**: Place emojis and stickers with drag-and-drop functionality
- **Color Filters**: Apply various color filters (transparent, white, blue, yellow, orange, red, green) with adjustable opacity
- **Image Rotation**: Rotate images by 90°, 180°, or 270° degrees
- **Image Cropping**: Crop images with multiple aspect ratio presets
- **Image to Video Conversion**: Convert static images to video format for enhanced editing

### 🎬 Video Editing
- **Speed Control**: Adjust video playback speed (0.5x, 0.75x, 1x, 2x, 3x)
- **Text Overlays**: Add animated text overlays to videos
- **Emoji Animation**: Place animated emojis and stickers on videos
- **Color Filters**: Apply color effects to videos with opacity control
- **Video Rotation**: Rotate videos using FFmpeg transpose filters
- **Video Splitting**: Split videos into segments
- **Video to GIF Conversion**: Convert video segments to animated GIFs
- **Thumbnail Generation**: Generate video thumbnails automatically

### 🎵 Audio Features
- **Audio Merging**: Combine audio tracks with video/images
- **Audio Looping**: Loop audio tracks for continuous playback
- **Audio Format Support**: Support for various audio formats

### 🎨 Advanced Features
- **Multi-Media Support**: Handle both local and remote media files
- **Real-time Preview**: Preview edits in real-time
- **Batch Processing**: Process multiple media files simultaneously
- **Gallery Integration**: Save processed media to device gallery
- **Camera Integration**: Direct camera capture and editing
- **Drag & Drop Interface**: Intuitive drag-and-drop editing interface

## 📦 Dependencies

### Core Dependencies
- **ffmpeg_kit_flutter_new**: ^2.0.0 - FFmpeg integration for media processing
- **video_player**: ^2.10.0 - Video playback and control
- **camera**: ^0.11.1 - Camera functionality
- **file_picker**: ^10.2.0 - File selection from gallery
- **audioplayers**: 6.5.0 - Audio playback capabilities

### State Management
- **bloc**: ^9.0.0 - State management architecture
- **flutter_bloc**: ^9.1.1 - Flutter BLoC integration
- **equatable**: ^2.0.7 - Value equality for state objects

### Image Processing
- **image**: ^4.5.4 - Image manipulation and processing
- **image_cropper**: ^9.1.0 - Image cropping functionality

### Utilities
- **gallery_saver_plus**: ^3.2.8 - Save media to device gallery
- **http**: HTTP requests for remote media
- **path_provider**: File system access
- **path**: Path manipulation utilities

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- FFmpeg support (handled by ffmpeg_kit_flutter_new)

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_ffmpeg_media_editor: ^1.0.0
```

### Basic Usage

```dart
import 'package:flutter_ffmpeg_media_editor/flutter_ffmpeg_media_editor.dart';

// Initialize the media editor
final mediaEditor = MediaEditingCubit();

// Add media for editing
final mediaModel = MediaModel(
  id: 'unique_id',
  filePath: '/path/to/media',
  mediaType: MediaType.localVideo,
);

// Process media with edits
await mediaEditor.processMedia(
  media: mediaModel,
  saveToGallery: true,
);
```

## 🏗️ Architecture

### State Management
The package uses BLoC (Business Logic Component) pattern for state management:

- **MediaEditingCubit**: Manages media editing operations and state
- **CameraCubit**: Handles camera functionality
- **SetupCubit**: Manages application setup and configuration
- **SoundCubit**: Controls audio-related operations
- **VideoPlayerCubit**: Manages video playback state

### Core Components

#### Models
- **MediaModel**: Represents a media item with all its properties and editing data
- **MediaStateData**: Holds the current state of media editing operations
- **SoundModel**: Represents audio tracks and their properties

#### Utilities
- **FfmpegFuncs**: Core FFmpeg operations for media processing
- **Utils**: Helper functions for file operations, image processing, and UI utilities

#### Enums
- **MediaType**: Defines different media types (local/remote, image/video)
- **ColorFilterWithName**: Available color filters
- **VideoSpeedEnum**: Video speed options
- **Transpose**: Video rotation options

## 🔧 Key Features Explained

### Text Overlay System
```dart
// Add text to media
final textInfo = TextInfo(
  text: "Hello World",
  x: 100,
  y: 100,
  color: Colors.white,
  fontSize: 20,
  fontWeight: FontWeight.bold,
  textAlign: TextAlign.center,
);
```

### Emoji/Sticker System
```dart
// Add emoji to media
final emojiInfo = EmojiInfo(
  image: "path/to/emoji.png",
  x: 50,
  y: 50,
  width: 100,
  height: 100,
  isGif: false,
  imageType: ImageType.local,
);
```

### Color Filter Application
```dart
// Apply color filter
mediaModel.color = ColorFilterWithName.blue;
mediaModel.colorOpacity = 0.5;
```

### Video Speed Adjustment
```dart
// Change video speed
final speedAdjustedVideo = await FfmpegFuncs.mergeVideoSpeed(
  videoPath: videoPath,
  speed: 2.0, // 2x speed
);
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web (limited functionality)
- ✅ Desktop (limited functionality)

## 🔒 Permissions

### Android
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture photos and videos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select and save media</string>
```

## 🐛 Troubleshooting

### Common Issues

1. **FFmpeg Processing Errors**
   - Ensure media files are in supported formats
   - Check file permissions
   - Verify sufficient storage space

2. **Memory Issues**
   - Process large files in smaller chunks
   - Implement proper cleanup of temporary files

3. **Performance Issues**
   - Use appropriate video quality settings
   - Implement background processing for heavy operations

## 🤝 Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- FFmpeg team for the powerful media processing library
- Flutter team for the framework
- All contributors and users of this package

## 📞 Support

If you encounter any issues or have questions:

- Create an issue on GitHub
- Check the documentation
- Review the example code

> **Note:**
> The codebase is well-structured and modular, designed for clarity and extensibility. However, some functionalities may have issues or bugs, as this project is evolving. These will be addressed and improved over time. The main focus of this repository is to inspire the community with the ideas, patterns, and techniques used here—feel free to explore, adapt, and build upon them!
---

## 📸 Screenshots

Below are real screenshots from the Blogs Chat app, powered by this media editor module:
![44](https://github.com/user-attachments/assets/10547cff-9f6c-4014-919f-389c248bdd64)
![33](https://github.com/user-attachments/assets/e1171f9c-de7c-4534-b525-7fc0e8cd46d0)
![22](https://github.com/user-attachments/assets/f796b63e-f736-4a6c-88a2-7b7dc0025f17)
![11](https://github.com/user-attachments/assets/8dd53937-f34b-4777-944a-39fe470662ef)
![55](https://github.com/user-attachments/assets/27fb139a-5c9f-42f3-bf0f-7a24b5d0637c)


**Made with ❤️ for the Flutter community**

