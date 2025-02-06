import 'package:cloud_firestore/cloud_firestore.dart';

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

  Video({
    required this.id,
    required this.url,
    required this.userId,
    required this.createdAt,
    this.description,
    required this.status,
    this.thumbnailUrl,
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
  }) {
    return Video(
      id: id ?? this.id,
      url: url ?? this.url,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      status: status ?? this.status,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
