import 'package:cloud_firestore/cloud_firestore.dart';

class VideoComment {
  final String id;
  final String videoId;
  final String userId;
  final String text;
  final DateTime timestamp;
  final int likeCount;
  final int replyCount;
  final String? parentCommentId; // null for top-level comments
  final String? userDisplayName; // Cached user display name
  final String? userProfileImage; // Cached user profile image

  VideoComment({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.text,
    required this.timestamp,
    this.likeCount = 0,
    this.replyCount = 0,
    this.parentCommentId,
    this.userDisplayName,
    this.userProfileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'videoId': videoId,
      'userId': userId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'likeCount': likeCount,
      'replyCount': replyCount,
      'parentCommentId': parentCommentId,
      'userDisplayName': userDisplayName,
      'userProfileImage': userProfileImage,
    };
  }

  factory VideoComment.fromMap(Map<String, dynamic> map) {
    return VideoComment(
      id: map['id'] as String,
      videoId: map['videoId'] as String,
      userId: map['userId'] as String,
      text: map['text'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likeCount: map['likeCount'] as int? ?? 0,
      replyCount: map['replyCount'] as int? ?? 0,
      parentCommentId: map['parentCommentId'] as String?,
      userDisplayName: map['userDisplayName'] as String?,
      userProfileImage: map['userProfileImage'] as String?,
    );
  }

  VideoComment copyWith({
    String? id,
    String? videoId,
    String? userId,
    String? text,
    DateTime? timestamp,
    int? likeCount,
    int? replyCount,
    String? parentCommentId,
    String? userDisplayName,
    String? userProfileImage,
  }) {
    return VideoComment(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
    );
  }
} 