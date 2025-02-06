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
      // Start a batch write
      final batch = _firestore.batch();
      
      // Remove the interaction
      final interactionRef = _firestore.collection(_collection).doc(interaction.id);
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
          .map((doc) => VideoInteraction.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw VideoException(
        'Failed to get user interactions: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }
} 