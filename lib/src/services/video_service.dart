import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/video.dart';
import '../repositories/video_repository.dart';
import '../utils/exceptions.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class VideoService {
  final FirebaseStorage _storage;
  final VideoRepository _videoRepository;
  final firebase_auth.FirebaseAuth _auth;
  UploadTask? _currentUploadTask;
  String? _currentVideoId;

  static const int _maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const List<String> _supportedFormats = ['.mp4', '.mov', '.avi'];

  VideoService({
    FirebaseStorage? storage,
    VideoRepository? videoRepository,
    firebase_auth.FirebaseAuth? auth,
  }) : _storage = storage ?? FirebaseStorage.instance,
       _videoRepository = videoRepository ?? VideoRepository(),
       _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  Future<void> validateVideo(File videoFile) async {
    try {
      final size = await videoFile.length();
      if (size > _maxVideoSize) {
        throw VideoException(
          'Video size exceeds 100MB limit',
          code: VideoException.videoTooLarge
        );
      }

      final ext = path.extension(videoFile.path).toLowerCase();
      if (!_supportedFormats.contains(ext)) {
        throw VideoException(
          'Unsupported video format. Supported formats: ${_supportedFormats.join(", ")}',
          code: VideoException.unsupportedFormat
        );
      }
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException('Failed to validate video: ${e.toString()}');
    }
  }

  Future<Video> uploadVideo(File videoFile, {
    String? description,
    void Function(double)? onProgress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw VideoException(
        'User not authenticated',
        code: VideoException.userNotAuthenticated
      );
    }

    try {
      // Validate video before upload
      await validateVideo(videoFile);

      // Generate unique ID for the video
      final videoId = const Uuid().v4();
      _currentVideoId = videoId;
      final videoFileName = path.basename(videoFile.path);
      final videoExt = path.extension(videoFileName);
      
      // Create storage reference
      final videoRef = _storage.ref()
          .child('videos')
          .child(user.uid)
          .child('$videoId$videoExt');

      // Create video metadata
      final video = Video(
        id: videoId,
        url: '', // Will be updated after upload
        userId: user.uid,
        createdAt: DateTime.now(),
        description: description,
        status: Video.statusUploading,
      );

      // Save initial video metadata
      await _videoRepository.saveVideo(video);

      // Upload video file
      _currentUploadTask = videoRef.putFile(videoFile);
      
      // Listen to upload progress
      _currentUploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final uploadTask = await _currentUploadTask!;
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update video with URL and status
      final updatedVideo = video.copyWith(
        url: downloadUrl,
        status: 'ready',
      );

      // Update video metadata
      await _videoRepository.updateVideoFromModel(updatedVideo);

      _currentUploadTask = null;
      _currentVideoId = null;
      return updatedVideo;
    } catch (e) {
      if (_currentVideoId != null) {
        try {
          // Update status to error if upload fails
          await _videoRepository.updateVideo(_currentVideoId!, {'status': 'error'});
        } catch (_) {
          // Ignore cleanup errors
        }
      }
      
      _currentUploadTask = null;
      _currentVideoId = null;

      if (e is VideoException) rethrow;
      throw VideoException(
        'Failed to upload video: ${e.toString()}',
        code: VideoException.uploadFailed
      );
    }
  }

  Future<void> cancelUpload() async {
    if (_currentUploadTask != null) {
      try {
        await _currentUploadTask!.cancel();
        _currentUploadTask = null;

        // Clean up video document if it exists
        if (_currentVideoId != null) {
          await _videoRepository.deleteVideo(_currentVideoId!);
          _currentVideoId = null;
        }
      } catch (e) {
        throw VideoException(
          'Failed to cancel upload: ${e.toString()}',
          code: VideoException.uploadFailed
        );
      }
    }
  }

  Future<List<Video>> getUserVideos(String userId) async {
    try {
      return await _videoRepository.getVideosByUserId(userId);
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException(
        'Failed to get user videos: ${e.toString()}',
        code: VideoException.videoNotFound
      );
    }
  }

  Future<void> deleteVideo(String videoId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw VideoException(
        'User not authenticated',
        code: VideoException.userNotAuthenticated
      );
    }

    try {
      // Get video data
      final video = await _videoRepository.getVideoById(videoId);
      if (video == null) {
        throw VideoException(
          'Video not found',
          code: VideoException.videoNotFound
        );
      }

      // Verify ownership
      if (video.userId != user.uid) {
        throw VideoException(
          'Not authorized to delete this video',
          code: VideoException.unauthorized
        );
      }

      // Delete from storage
      if (video.url.isNotEmpty) {
        final videoRef = _storage.refFromURL(video.url);
        await videoRef.delete();
      }

      // Delete thumbnail if exists
      if (video.thumbnailUrl != null) {
        final thumbnailRef = _storage.refFromURL(video.thumbnailUrl!);
        await thumbnailRef.delete();
      }

      // Delete from Firestore
      await _videoRepository.deleteVideo(videoId);
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException(
        'Failed to delete video: ${e.toString()}',
        code: VideoException.deleteFailed
      );
    }
  }

  Stream<Video?> getVideoStream(String videoId) {
    return _videoRepository.getVideoStream(videoId);
  }

  Stream<List<Video>> getUserVideosStream(String userId) {
    return _videoRepository.getUserVideosStream(userId);
  }

  Future<Video> publishVideo(String videoId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw VideoException(
        'User not authenticated',
        code: VideoException.userNotAuthenticated
      );
    }

    try {
      final video = await _videoRepository.getVideoById(videoId);
      if (video == null) {
        throw VideoException(
          'Video not found',
          code: VideoException.videoNotFound
        );
      }

      if (video.userId != user.uid) {
        throw VideoException(
          'Not authorized to publish this video',
          code: VideoException.unauthorized
        );
      }

      if (video.status != Video.statusReady && video.status != Video.statusDraft) {
        throw VideoException(
          'Video must be ready before publishing',
          code: VideoException.invalidOperation
        );
      }

      final updatedVideo = video.copyWith(status: Video.statusPublished);
      await _videoRepository.updateVideoFromModel(updatedVideo);
      return updatedVideo;
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException(
        'Failed to publish video: ${e.toString()}',
        code: VideoException.publishFailed
      );
    }
  }

  Future<Video> unpublishVideo(String videoId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw VideoException(
        'User not authenticated',
        code: VideoException.userNotAuthenticated
      );
    }

    try {
      final video = await _videoRepository.getVideoById(videoId);
      if (video == null) {
        throw VideoException(
          'Video not found',
          code: VideoException.videoNotFound
        );
      }

      if (video.userId != user.uid) {
        throw VideoException(
          'Not authorized to unpublish this video',
          code: VideoException.unauthorized
        );
      }

      if (video.status != Video.statusPublished) {
        throw VideoException(
          'Video is not published',
          code: VideoException.invalidOperation
        );
      }

      final updatedVideo = video.copyWith(status: Video.statusDraft);
      await _videoRepository.updateVideoFromModel(updatedVideo);
      return updatedVideo;
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException(
        'Failed to unpublish video: ${e.toString()}',
        code: VideoException.unpublishFailed
      );
    }
  }

  // Get published videos for all users
  Future<List<Video>> getPublishedVideos() async {
    try {
      return await _videoRepository.getVideosByStatus(Video.statusPublished);
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException(
        'Failed to get published videos: ${e.toString()}',
        code: VideoException.videoNotFound
      );
    }
  }

  // Get user's published videos
  Future<List<Video>> getUserPublishedVideos(String userId) async {
    try {
      return await _videoRepository.getVideosByUserIdAndStatus(
        userId,
        Video.statusPublished
      );
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException(
        'Failed to get user published videos: ${e.toString()}',
        code: VideoException.videoNotFound
      );
    }
  }

  // Get user's draft videos
  Future<List<Video>> getUserDraftVideos(String userId) async {
    try {
      return await _videoRepository.getVideosByUserIdAndStatus(
        userId,
        Video.statusDraft
      );
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException(
        'Failed to get user draft videos: ${e.toString()}',
        code: VideoException.videoNotFound
      );
    }
  }
}
