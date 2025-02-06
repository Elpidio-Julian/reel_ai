// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_comment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoCommentRepositoryHash() =>
    r'3199f868b6e0f82c7299945c6a3136faf74950fb';

/// See also [videoCommentRepository].
@ProviderFor(videoCommentRepository)
final videoCommentRepositoryProvider =
    Provider<VideoCommentRepository>.internal(
  videoCommentRepository,
  name: r'videoCommentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoCommentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideoCommentRepositoryRef = ProviderRef<VideoCommentRepository>;
String _$videoCommentsHash() => r'abe8283771677c374f505fef2832eedc365c62c1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [videoComments].
@ProviderFor(videoComments)
const videoCommentsProvider = VideoCommentsFamily();

/// See also [videoComments].
class VideoCommentsFamily extends Family<AsyncValue<List<VideoComment>>> {
  /// See also [videoComments].
  const VideoCommentsFamily();

  /// See also [videoComments].
  VideoCommentsProvider call(
    String videoId, {
    int limit = 20,
  }) {
    return VideoCommentsProvider(
      videoId,
      limit: limit,
    );
  }

  @override
  VideoCommentsProvider getProviderOverride(
    covariant VideoCommentsProvider provider,
  ) {
    return call(
      provider.videoId,
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoCommentsProvider';
}

/// See also [videoComments].
class VideoCommentsProvider
    extends AutoDisposeStreamProvider<List<VideoComment>> {
  /// See also [videoComments].
  VideoCommentsProvider(
    String videoId, {
    int limit = 20,
  }) : this._internal(
          (ref) => videoComments(
            ref as VideoCommentsRef,
            videoId,
            limit: limit,
          ),
          from: videoCommentsProvider,
          name: r'videoCommentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoCommentsHash,
          dependencies: VideoCommentsFamily._dependencies,
          allTransitiveDependencies:
              VideoCommentsFamily._allTransitiveDependencies,
          videoId: videoId,
          limit: limit,
        );

  VideoCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoId,
    required this.limit,
  }) : super.internal();

  final String videoId;
  final int limit;

  @override
  Override overrideWith(
    Stream<List<VideoComment>> Function(VideoCommentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VideoCommentsProvider._internal(
        (ref) => create(ref as VideoCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoId: videoId,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<VideoComment>> createElement() {
    return _VideoCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoCommentsProvider &&
        other.videoId == videoId &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoId.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoCommentsRef on AutoDisposeStreamProviderRef<List<VideoComment>> {
  /// The parameter `videoId` of this provider.
  String get videoId;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _VideoCommentsProviderElement
    extends AutoDisposeStreamProviderElement<List<VideoComment>>
    with VideoCommentsRef {
  _VideoCommentsProviderElement(super.provider);

  @override
  String get videoId => (origin as VideoCommentsProvider).videoId;
  @override
  int get limit => (origin as VideoCommentsProvider).limit;
}

String _$commentRepliesHash() => r'd2c308b526df10dfffd1502d22a5316ec0520bce';

/// See also [commentReplies].
@ProviderFor(commentReplies)
const commentRepliesProvider = CommentRepliesFamily();

/// See also [commentReplies].
class CommentRepliesFamily extends Family<AsyncValue<List<VideoComment>>> {
  /// See also [commentReplies].
  const CommentRepliesFamily();

  /// See also [commentReplies].
  CommentRepliesProvider call(
    String commentId, {
    String? lastReplyId,
    int limit = 10,
  }) {
    return CommentRepliesProvider(
      commentId,
      lastReplyId: lastReplyId,
      limit: limit,
    );
  }

  @override
  CommentRepliesProvider getProviderOverride(
    covariant CommentRepliesProvider provider,
  ) {
    return call(
      provider.commentId,
      lastReplyId: provider.lastReplyId,
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'commentRepliesProvider';
}

/// See also [commentReplies].
class CommentRepliesProvider
    extends AutoDisposeFutureProvider<List<VideoComment>> {
  /// See also [commentReplies].
  CommentRepliesProvider(
    String commentId, {
    String? lastReplyId,
    int limit = 10,
  }) : this._internal(
          (ref) => commentReplies(
            ref as CommentRepliesRef,
            commentId,
            lastReplyId: lastReplyId,
            limit: limit,
          ),
          from: commentRepliesProvider,
          name: r'commentRepliesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commentRepliesHash,
          dependencies: CommentRepliesFamily._dependencies,
          allTransitiveDependencies:
              CommentRepliesFamily._allTransitiveDependencies,
          commentId: commentId,
          lastReplyId: lastReplyId,
          limit: limit,
        );

  CommentRepliesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.commentId,
    required this.lastReplyId,
    required this.limit,
  }) : super.internal();

  final String commentId;
  final String? lastReplyId;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<VideoComment>> Function(CommentRepliesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommentRepliesProvider._internal(
        (ref) => create(ref as CommentRepliesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        commentId: commentId,
        lastReplyId: lastReplyId,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VideoComment>> createElement() {
    return _CommentRepliesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentRepliesProvider &&
        other.commentId == commentId &&
        other.lastReplyId == lastReplyId &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, commentId.hashCode);
    hash = _SystemHash.combine(hash, lastReplyId.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommentRepliesRef on AutoDisposeFutureProviderRef<List<VideoComment>> {
  /// The parameter `commentId` of this provider.
  String get commentId;

  /// The parameter `lastReplyId` of this provider.
  String? get lastReplyId;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _CommentRepliesProviderElement
    extends AutoDisposeFutureProviderElement<List<VideoComment>>
    with CommentRepliesRef {
  _CommentRepliesProviderElement(super.provider);

  @override
  String get commentId => (origin as CommentRepliesProvider).commentId;
  @override
  String? get lastReplyId => (origin as CommentRepliesProvider).lastReplyId;
  @override
  int get limit => (origin as CommentRepliesProvider).limit;
}

String _$paginatedVideoCommentsHash() =>
    r'f20b00d3cfe7c88d83db1ce2b13f804f7e7a3d3d';

/// See also [paginatedVideoComments].
@ProviderFor(paginatedVideoComments)
const paginatedVideoCommentsProvider = PaginatedVideoCommentsFamily();

/// See also [paginatedVideoComments].
class PaginatedVideoCommentsFamily
    extends Family<AsyncValue<List<VideoComment>>> {
  /// See also [paginatedVideoComments].
  const PaginatedVideoCommentsFamily();

  /// See also [paginatedVideoComments].
  PaginatedVideoCommentsProvider call(
    String videoId, {
    String? lastCommentId,
    int limit = 20,
  }) {
    return PaginatedVideoCommentsProvider(
      videoId,
      lastCommentId: lastCommentId,
      limit: limit,
    );
  }

  @override
  PaginatedVideoCommentsProvider getProviderOverride(
    covariant PaginatedVideoCommentsProvider provider,
  ) {
    return call(
      provider.videoId,
      lastCommentId: provider.lastCommentId,
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'paginatedVideoCommentsProvider';
}

/// See also [paginatedVideoComments].
class PaginatedVideoCommentsProvider
    extends AutoDisposeFutureProvider<List<VideoComment>> {
  /// See also [paginatedVideoComments].
  PaginatedVideoCommentsProvider(
    String videoId, {
    String? lastCommentId,
    int limit = 20,
  }) : this._internal(
          (ref) => paginatedVideoComments(
            ref as PaginatedVideoCommentsRef,
            videoId,
            lastCommentId: lastCommentId,
            limit: limit,
          ),
          from: paginatedVideoCommentsProvider,
          name: r'paginatedVideoCommentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$paginatedVideoCommentsHash,
          dependencies: PaginatedVideoCommentsFamily._dependencies,
          allTransitiveDependencies:
              PaginatedVideoCommentsFamily._allTransitiveDependencies,
          videoId: videoId,
          lastCommentId: lastCommentId,
          limit: limit,
        );

  PaginatedVideoCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoId,
    required this.lastCommentId,
    required this.limit,
  }) : super.internal();

  final String videoId;
  final String? lastCommentId;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<VideoComment>> Function(PaginatedVideoCommentsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PaginatedVideoCommentsProvider._internal(
        (ref) => create(ref as PaginatedVideoCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoId: videoId,
        lastCommentId: lastCommentId,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VideoComment>> createElement() {
    return _PaginatedVideoCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaginatedVideoCommentsProvider &&
        other.videoId == videoId &&
        other.lastCommentId == lastCommentId &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoId.hashCode);
    hash = _SystemHash.combine(hash, lastCommentId.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PaginatedVideoCommentsRef
    on AutoDisposeFutureProviderRef<List<VideoComment>> {
  /// The parameter `videoId` of this provider.
  String get videoId;

  /// The parameter `lastCommentId` of this provider.
  String? get lastCommentId;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _PaginatedVideoCommentsProviderElement
    extends AutoDisposeFutureProviderElement<List<VideoComment>>
    with PaginatedVideoCommentsRef {
  _PaginatedVideoCommentsProviderElement(super.provider);

  @override
  String get videoId => (origin as PaginatedVideoCommentsProvider).videoId;
  @override
  String? get lastCommentId =>
      (origin as PaginatedVideoCommentsProvider).lastCommentId;
  @override
  int get limit => (origin as PaginatedVideoCommentsProvider).limit;
}

String _$videoCommentControllerHash() =>
    r'40d60891caea4e03c25b49204b69df3e18cfa001';

/// See also [VideoCommentController].
@ProviderFor(VideoCommentController)
final videoCommentControllerProvider =
    AsyncNotifierProvider<VideoCommentController, void>.internal(
  VideoCommentController.new,
  name: r'videoCommentControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoCommentControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VideoCommentController = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
