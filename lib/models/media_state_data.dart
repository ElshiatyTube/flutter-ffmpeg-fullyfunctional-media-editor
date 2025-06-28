import 'package:equatable/equatable.dart';
import 'media_model.dart';

/// Represents the state data for media editing operations.
/// This class holds the current state of media items and their editing progress.
/// It extends Equatable for easy state comparison in BLoC pattern.
class MediaStateData extends Equatable {
  /// Total time in seconds allocated for the media composition
  final num timeInSec;
  
  /// List of media items (images/videos) in the current composition
  final List<MediaModel> medias;

  /// Creates a new MediaStateData instance
  /// 
  /// [timeInSec] - Total duration in seconds (default: 60 seconds)
  /// [medias] - List of media models (default: empty list)
  const MediaStateData({
    this.timeInSec = 60,
    this.medias = const [],
  });

  /// Creates a copy of this MediaStateData with updated values
  /// 
  /// [currentReelsTime] - New time duration for reels
  /// [currentPostTime] - New time duration for posts (currently unused parameter)
  /// [medias] - Updated list of media models
  /// 
  /// Returns a new MediaStateData instance with the specified changes
  MediaStateData copyWith({
    num? currentReelsTime,
    num? currentPostTime,
    List<MediaModel>? medias,
  }) {
    return MediaStateData(
      timeInSec: currentReelsTime ?? this.timeInSec,
      medias: medias ?? this.medias,
    );
  }

  /// Returns the list of properties used for equality comparison
  /// This is required by Equatable for proper state comparison
  @override
  List<Object?> get props => [
    timeInSec,
    medias,
  ];
} 