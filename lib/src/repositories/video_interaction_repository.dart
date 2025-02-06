import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_interaction.dart';
import '../models/video_stats.dart';
import '../utils/exceptions.dart';

class VideoInteractionRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'interactions';
  final String _statsCollection = 'video_stats';

  VideoInteractionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Add an interaction (like, share, save)
  Future<VideoInteraction> addInteraction(VideoInteraction interaction) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();
      
      // Add the interaction
      final interactionRef = _firestore.collection(_collection).doc(interaction.id);
      batch.set(interactionRef, interaction.toMap());

      // Update video stats
      final statsRef = _firestore.collection(_statsCollection).doc(interaction.videoId);
      batch.set(statsRef, {
        'videoId': interaction.videoId,
        '${interaction.type}Count': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Commit the batch
      await batch.commit();
      return interaction;
    } catch (e) {
      throw VideoException(
        'Failed to add interaction: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Remove an interaction
  Future<void> removeInteraction(VideoInteraction interaction) async {
    try {
      // Find the existing interaction first
      final existingInteractionQuery = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: interaction.userId)
          .where('videoId', isEqualTo: interaction.videoId)
          .where('type', isEqualTo: interaction.type)
          .limit(1)
          .get();

      if (existingInteractionQuery.docs.isEmpty) {
        // No interaction to remove
        return;
      }

      final existingInteractionDoc = existingInteractionQuery.docs.first;
      
      // Start a batch write
      final batch = _firestore.batch();
      
      // Remove the interaction
      final interactionRef = _firestore.collection(_collection).doc(existingInteractionDoc.id);
      batch.delete(interactionRef);

      // Update video stats
      final statsRef = _firestore.collection(_statsCollection).doc(interaction.videoId);
      batch.set(statsRef, {
        'videoId': interaction.videoId,
        '${interaction.type}Count': FieldValue.increment(-1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw VideoException(
        'Failed to remove interaction: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Check if user has interacted with video
  Future<bool> hasUserInteraction(String userId, String videoId, String type) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('videoId', isEqualTo: videoId)
          .where('type', isEqualTo: type)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw VideoException(
        'Failed to check interaction: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Get video stats
  Future<VideoStats?> getVideoStats(String videoId) async {
    try {
      final doc = await _firestore
          .collection(_statsCollection)
          .doc(videoId)
          .get();

      if (!doc.exists) return null;
      return VideoStats.fromMap(doc.data()!);
    } catch (e) {
      throw VideoException(
        'Failed to get video stats: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Stream video stats
  Stream<VideoStats?> streamVideoStats(String videoId) {
    return _firestore
        .collection(_statsCollection)
        .doc(videoId)
        .snapshots()
        .map((doc) => doc.exists ? VideoStats.fromMap(doc.data()!) : null);
  }

  // Get user interactions for a video
  Future<List<VideoInteraction>> getUserInteractions(String userId, String videoId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('videoId', isEqualTo: videoId)
          .get();

      return snapshot.docs
          .map((doc) => VideoInteraction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw VideoException(
        'Failed to get user interactions: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Stream user interaction status
  Stream<bool> streamUserInteraction(String userId, String videoId, String type) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('videoId', isEqualTo: videoId)
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  // Stream all user interactions for a video
  Stream<List<VideoInteraction>> streamUserInteractions(String userId, String videoId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('videoId', isEqualTo: videoId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VideoInteraction.fromMap(doc.data(), doc.id))
            .toList());
  }
} 