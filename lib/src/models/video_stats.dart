import 'package:cloud_firestore/cloud_firestore.dart';

class VideoStats {
  final String videoId;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int saveCount;
  final DateTime lastUpdated;

  VideoStats({
    required this.videoId,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.saveCount = 0,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'saveCount': saveCount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory VideoStats.fromMap(Map<String, dynamic> map) {
    return VideoStats(
      videoId: map['videoId'] as String,
      viewCount: map['viewCount'] as int? ?? 0,
      likeCount: map['likeCount'] as int? ?? 0,
      commentCount: map['commentCount'] as int? ?? 0,
      shareCount: map['shareCount'] as int? ?? 0,
      saveCount: map['saveCount'] as int? ?? 0,
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }

  VideoStats copyWith({
    String? videoId,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? saveCount,
    DateTime? lastUpdated,
  }) {
    return VideoStats(
      videoId: videoId ?? this.videoId,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      saveCount: saveCount ?? this.saveCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  VideoStats incrementStat(String statType) {
    switch (statType) {
      case 'view':
        return copyWith(viewCount: viewCount + 1, lastUpdated: DateTime.now());
      case 'like':
        return copyWith(likeCount: likeCount + 1, lastUpdated: DateTime.now());
      case 'comment':
        return copyWith(commentCount: commentCount + 1, lastUpdated: DateTime.now());
      case 'share':
        return copyWith(shareCount: shareCount + 1, lastUpdated: DateTime.now());
      case 'save':
        return copyWith(saveCount: saveCount + 1, lastUpdated: DateTime.now());
      default:
        return this;
    }
  }

  VideoStats decrementStat(String statType) {
    switch (statType) {
      case 'like':
        return copyWith(likeCount: likeCount - 1, lastUpdated: DateTime.now());
      case 'comment':
        return copyWith(commentCount: commentCount - 1, lastUpdated: DateTime.now());
      case 'share':
        return copyWith(shareCount: shareCount - 1, lastUpdated: DateTime.now());
      case 'save':
        return copyWith(saveCount: saveCount - 1, lastUpdated: DateTime.now());
      default:
        return this;
    }
  }
} 