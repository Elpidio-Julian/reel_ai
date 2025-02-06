import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/video.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class VideoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  UploadTask? _currentUploadTask;
  String? _currentVideoId;

  static const int _maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const List<String> _supportedFormats = ['.mp4', '.mov', '.avi'];

  Future<void> validateVideo(File videoFile) async {
    final size = await videoFile.length();
    if (size > _maxVideoSize) {
      throw Exception('Video size exceeds 100MB limit');
    }

    final ext = path.extension(videoFile.path).toLowerCase();
    if (!_supportedFormats.contains(ext)) {
      throw Exception('Unsupported video format. Supported formats: ${_supportedFormats.join(", ")}');
    }
  }

  Future<Video> uploadVideo(File videoFile, {
    String? description,
    void Function(double)? onProgress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

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
      status: 'uploading',
    );

    // Save initial video metadata
    await _firestore
        .collection('videos')
        .doc(videoId)
        .set(video.toMap());

    // Upload video file
    try {
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

      // Update video metadata in Firestore
      await _firestore
          .collection('videos')
          .doc(videoId)
          .update(updatedVideo.toMap());

      _currentUploadTask = null;
      _currentVideoId = null;
      return updatedVideo;
    } catch (e) {
      // Update status to error if upload fails
      await _firestore
          .collection('videos')
          .doc(videoId)
          .update({'status': 'error'});
      
      _currentUploadTask = null;
      _currentVideoId = null;
      rethrow;
    }
  }

  Future<void> cancelUpload() async {
    if (_currentUploadTask != null) {
      await _currentUploadTask!.cancel();
      _currentUploadTask = null;

      // Clean up Firestore document if it exists
      if (_currentVideoId != null) {
        try {
          await _firestore
              .collection('videos')
              .doc(_currentVideoId)
              .delete();
        } catch (e) {
          // Ignore cleanup errors
        }
        _currentVideoId = null;
      }
    }
  }

  Future<List<Video>> getUserVideos(String userId) async {
    final snapshot = await _firestore
        .collection('videos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Video.fromMap(doc.data()))
        .toList();
  }

  Future<void> deleteVideo(String videoId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Get video data
    final videoDoc = await _firestore
        .collection('videos')
        .doc(videoId)
        .get();

    if (!videoDoc.exists) {
      throw Exception('Video not found');
    }

    final video = Video.fromMap(videoDoc.data()!);

    // Verify ownership
    if (video.userId != user.uid) {
      throw Exception('Not authorized to delete this video');
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
    await _firestore
        .collection('videos')
        .doc(videoId)
        .delete();
  }
}
