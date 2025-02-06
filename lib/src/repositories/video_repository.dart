import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video.dart';
import '../utils/exceptions.dart';

class VideoRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'videos';

  VideoRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create or update video
  Future<void> saveVideo(Video video) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(video.id)
          .set(video.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw VideoException('Failed to save video data: ${e.toString()}');
    }
  }

  // Get video by ID
  Future<Video?> getVideoById(String videoId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(videoId).get();
      if (!doc.exists) return null;
      return Video.fromMap(doc.data()!);
    } catch (e) {
      throw VideoException('Failed to fetch video data: ${e.toString()}');
    }
  }

  // Get videos by user ID
  Future<List<Video>> getVideosByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Video.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw VideoException('Failed to fetch user videos: ${e.toString()}');
    }
  }

  // Update video fields
  Future<void> updateVideo(String videoId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(videoId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw VideoException('Failed to update video data: ${e.toString()}');
    }
  }

  // Update video from model
  Future<void> updateVideoFromModel(Video video) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(video.id)
          .update(video.toMap());
    } catch (e) {
      throw VideoException('Failed to update video data: ${e.toString()}');
    }
  }

  // Delete video
  Future<void> deleteVideo(String videoId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(videoId)
          .delete();
    } catch (e) {
      throw VideoException('Failed to delete video data: ${e.toString()}');
    }
  }

  // Stream video changes
  Stream<Video?> getVideoStream(String videoId) {
    return _firestore
        .collection(_collection)
        .doc(videoId)
        .snapshots()
        .map((doc) => doc.exists ? Video.fromMap(doc.data()!) : null);
  }

  // Stream user's videos
  Stream<List<Video>> getUserVideosStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Video.fromMap(doc.data()))
            .toList());
  }
} 