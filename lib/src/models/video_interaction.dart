import 'package:cloud_firestore/cloud_firestore.dart';

class VideoInteraction {
  static const String typeLike = 'like';
  static const String typeShare = 'share';
  static const String typeSave = 'save';

  final String id;
  final String videoId;
  final String userId;
  final String type;
  final DateTime timestamp;

  VideoInteraction({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'videoId': videoId,
      'userId': userId,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory VideoInteraction.fromMap(Map<String, dynamic> map) {
    return VideoInteraction(
      id: map['id'] as String,
      videoId: map['videoId'] as String,
      userId: map['userId'] as String,
      type: map['type'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  VideoInteraction copyWith({
    String? id,
    String? videoId,
    String? userId,
    String? type,
    DateTime? timestamp,
  }) {
    return VideoInteraction(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }
} 