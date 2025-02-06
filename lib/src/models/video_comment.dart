import 'package:cloud_firestore/cloud_firestore.dart';

class VideoComment {
  final String id;
  final String videoId;
  final String userId;
  final String? userDisplayName;
  final String? userProfileImage;
  final String text;
  final DateTime timestamp;
  final int likeCount;
  final String? parentCommentId;
  final int replies;

  VideoComment({
    required this.id,
    required this.videoId,
    required this.userId,
    this.userDisplayName,
    this.userProfileImage,
    required this.text,
    required this.timestamp,
    this.likeCount = 0,
    this.parentCommentId,
    this.replies = 0,
  });

  factory VideoComment.fromMap(Map<String, dynamic> map, String id) {
    return VideoComment(
      id: id,
      videoId: map['videoId'] as String,
      userId: map['userId'] as String,
      userDisplayName: map['userDisplayName'] as String?,
      userProfileImage: map['userProfileImage'] as String?,
      text: map['text'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likeCount: map['likeCount'] as int? ?? 0,
      parentCommentId: map['parentCommentId'] as String?,
      replies: map['replies'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userProfileImage': userProfileImage,
      'text': text,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'parentCommentId': parentCommentId,
      'replies': replies,
    };
  }

  VideoComment copyWith({
    String? id,
    String? videoId,
    String? userId,
    String? userDisplayName,
    String? userProfileImage,
    String? text,
    DateTime? timestamp,
    int? likeCount,
    String? parentCommentId,
    int? replies,
  }) {
    return VideoComment(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replies: replies ?? this.replies,
    );
  }
} 