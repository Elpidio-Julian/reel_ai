import 'package:cloud_firestore/cloud_firestore.dart';
import 'video_stats.dart';

class Video {
  // Video status constants
  static const String statusUploading = 'uploading';
  static const String statusProcessing = 'processing';
  static const String statusReady = 'ready';
  static const String statusPublished = 'published';
  static const String statusError = 'error';
  static const String statusDraft = 'draft';

  final String id;
  final String url;
  final String userId;
  final DateTime createdAt;
  final String? description;
  final String status; // uploading, processing, ready, published, error, draft
  final String? thumbnailUrl;
  final VideoStats? stats; // New field for stats
  final String? userDisplayName; // Cached user display name
  final String? userProfileImage; // Cached user profile image
  final bool commentsEnabled; // New field to control comments
  final List<String>? hashtags; // New field for searchability
  final String? music; // New field for background music info
  final Map<String, dynamic>? metadata; // New field for additional metadata

  Video({
    required this.id,
    required this.url,
    required this.userId,
    required this.createdAt,
    this.description,
    required this.status,
    this.thumbnailUrl,
    this.stats,
    this.userDisplayName,
    this.userProfileImage,
    this.commentsEnabled = true,
    this.hashtags,
    this.music,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      'status': status,
      'thumbnailUrl': thumbnailUrl,
      'stats': stats?.toMap(),
      'userDisplayName': userDisplayName,
      'userProfileImage': userProfileImage,
      'commentsEnabled': commentsEnabled,
      'hashtags': hashtags,
      'music': music,
      'metadata': metadata,
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'] as String,
      url: map['url'] as String,
      userId: map['userId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      description: map['description'] as String?,
      status: map['status'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      stats: map['stats'] != null ? VideoStats.fromMap(map['stats'] as Map<String, dynamic>) : null,
      userDisplayName: map['userDisplayName'] as String?,
      userProfileImage: map['userProfileImage'] as String?,
      commentsEnabled: map['commentsEnabled'] as bool? ?? true,
      hashtags: map['hashtags'] != null ? List<String>.from(map['hashtags'] as List) : null,
      music: map['music'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Video copyWith({
    String? id,
    String? url,
    String? userId,
    DateTime? createdAt,
    String? description,
    String? status,
    String? thumbnailUrl,
    VideoStats? stats,
    String? userDisplayName,
    String? userProfileImage,
    bool? commentsEnabled,
    List<String>? hashtags,
    String? music,
    Map<String, dynamic>? metadata,
  }) {
    return Video(
      id: id ?? this.id,
      url: url ?? this.url,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      status: status ?? this.status,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      stats: stats ?? this.stats,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      hashtags: hashtags ?? this.hashtags,
      music: music ?? this.music,
      metadata: metadata ?? this.metadata,
    );
  }
}
