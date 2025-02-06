import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_comment.dart';
import '../utils/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VideoCommentRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'comments';
  final String _statsCollection = 'video_stats';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  VideoCommentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Add a comment
  Future<VideoComment> addComment(VideoComment comment) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();
      
      // Add the comment
      final commentRef = _firestore.collection(_collection).doc(comment.id);
      batch.set(commentRef, comment.toMap());

      // Update video stats
      final statsRef = _firestore.collection(_statsCollection).doc(comment.videoId);
      batch.set(statsRef, {
        'videoId': comment.videoId,
        'commentCount': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // If this is a reply, update parent comment's reply count
      if (comment.parentCommentId != null) {
        final parentRef = _firestore.collection(_collection).doc(comment.parentCommentId);
        batch.update(parentRef, {
          'replyCount': FieldValue.increment(1),
        });
      }

      // Commit the batch
      await batch.commit();
      return comment;
    } catch (e) {
      throw VideoException(
        'Failed to add comment: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Delete a comment
  Future<void> deleteComment(VideoComment comment) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();
      
      // Delete the comment
      final commentRef = _firestore.collection(_collection).doc(comment.id);
      batch.delete(commentRef);

      // Update video stats
      final statsRef = _firestore.collection(_statsCollection).doc(comment.videoId);
      batch.set(statsRef, {
        'videoId': comment.videoId,
        'commentCount': FieldValue.increment(-1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // If this is a reply, update parent comment's reply count
      if (comment.parentCommentId != null) {
        final parentRef = _firestore.collection(_collection).doc(comment.parentCommentId);
        batch.update(parentRef, {
          'replyCount': FieldValue.increment(-1),
        });
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw VideoException(
        'Failed to delete comment: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Get comments for a video
  Future<List<VideoComment>> getVideoComments(String videoId, {
    String? lastCommentId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('videoId', isEqualTo: videoId)
          .where('parentCommentId', isNull: true) // Only top-level comments
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (lastCommentId != null) {
        final lastDoc = await _firestore
            .collection(_collection)
            .doc(lastCommentId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => VideoComment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw VideoException(
        'Failed to get video comments: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Get replies for a comment
  Future<List<VideoComment>> getCommentReplies(String commentId, {
    String? lastReplyId,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('parentCommentId', isEqualTo: commentId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (lastReplyId != null) {
        final lastDoc = await _firestore
            .collection(_collection)
            .doc(lastReplyId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => VideoComment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw VideoException(
        'Failed to get comment replies: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Stream comments for a video
  Stream<List<VideoComment>> streamVideoComments(String videoId, {int limit = 20}) {
    return _firestore
        .collection(_collection)
        .where('videoId', isEqualTo: videoId)
        .where('parentCommentId', isNull: true)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VideoComment.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Like/Unlike a comment
  Future<void> toggleCommentLike(String commentId, bool like) async {
    try {
      final batch = _firestore.batch();
      final commentRef = _firestore.collection(_collection).doc(commentId);
      final likeRef = _firestore.collection('comment_likes').doc('${commentId}_${_auth.currentUser?.uid}');

      if (like) {
        // Add like document
        batch.set(likeRef, {
          'commentId': commentId,
          'userId': _auth.currentUser?.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        // Increment like count
        batch.update(commentRef, {
          'likeCount': FieldValue.increment(1),
        });
      } else {
        // Remove like document
        batch.delete(likeRef);
        // Decrement like count
        batch.update(commentRef, {
          'likeCount': FieldValue.increment(-1),
        });
      }

      await batch.commit();
    } catch (e) {
      throw VideoException(
        'Failed to toggle comment like: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Check if user has liked a comment
  Future<bool> hasUserLikedComment(String commentId, String userId) async {
    try {
      final doc = await _firestore
          .collection('comment_likes')
          .doc('${commentId}_$userId')
          .get();
      return doc.exists;
    } catch (e) {
      throw VideoException(
        'Failed to check comment like: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }

  // Update a comment
  Future<void> updateComment(String commentId, String newText) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(commentId)
          .update({
            'text': newText,
          });
    } catch (e) {
      throw VideoException(
        'Failed to update comment: ${e.toString()}',
        code: VideoException.invalidOperation,
      );
    }
  }
} 