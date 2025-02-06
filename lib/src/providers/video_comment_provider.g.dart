// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_comment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoCommentRepositoryHash() =>
    r'6a759c4ddc27981d47742e1f839ebae12e025897';

/// See also [videoCommentRepository].
@ProviderFor(videoCommentRepository)
final videoCommentRepositoryProvider =
    AutoDisposeProvider<VideoCommentRepository>.internal(
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
typedef VideoCommentRepositoryRef
    = AutoDisposeProviderRef<VideoCommentRepository>;
String _$videoCommentsHash() => r'd3f75e18068fe1ea34d12f14f3920247ecf76d75';

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
    String videoId,
  ) {
    return VideoCommentsProvider(
      videoId,
    );
  }

  @override
  VideoCommentsProvider getProviderOverride(
    covariant VideoCommentsProvider provider,
  ) {
    return call(
      provider.videoId,
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
    String videoId,
  ) : this._internal(
          (ref) => videoComments(
            ref as VideoCommentsRef,
            videoId,
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
        );

  VideoCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoId,
  }) : super.internal();

  final String videoId;

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
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<VideoComment>> createElement() {
    return _VideoCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoCommentsProvider && other.videoId == videoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoCommentsRef on AutoDisposeStreamProviderRef<List<VideoComment>> {
  /// The parameter `videoId` of this provider.
  String get videoId;
}

class _VideoCommentsProviderElement
    extends AutoDisposeStreamProviderElement<List<VideoComment>>
    with VideoCommentsRef {
  _VideoCommentsProviderElement(super.provider);

  @override
  String get videoId => (origin as VideoCommentsProvider).videoId;
}

String _$commentRepliesHash() => r'10bd2683ededd242440fe3132be7eb56a02c043a';

/// See also [commentReplies].
@ProviderFor(commentReplies)
const commentRepliesProvider = CommentRepliesFamily();

/// See also [commentReplies].
class CommentRepliesFamily extends Family<AsyncValue<List<VideoComment>>> {
  /// See also [commentReplies].
  const CommentRepliesFamily();

  /// See also [commentReplies].
  CommentRepliesProvider call(
    String commentId,
  ) {
    return CommentRepliesProvider(
      commentId,
    );
  }

  @override
  CommentRepliesProvider getProviderOverride(
    covariant CommentRepliesProvider provider,
  ) {
    return call(
      provider.commentId,
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
    String commentId,
  ) : this._internal(
          (ref) => commentReplies(
            ref as CommentRepliesRef,
            commentId,
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
        );

  CommentRepliesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.commentId,
  }) : super.internal();

  final String commentId;

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
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VideoComment>> createElement() {
    return _CommentRepliesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentRepliesProvider && other.commentId == commentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, commentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommentRepliesRef on AutoDisposeFutureProviderRef<List<VideoComment>> {
  /// The parameter `commentId` of this provider.
  String get commentId;
}

class _CommentRepliesProviderElement
    extends AutoDisposeFutureProviderElement<List<VideoComment>>
    with CommentRepliesRef {
  _CommentRepliesProviderElement(super.provider);

  @override
  String get commentId => (origin as CommentRepliesProvider).commentId;
}

String _$paginatedVideoCommentsHash() =>
    r'2aaab7d577ccf9ea402695224e00c6a532617c09';

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

String _$hasUserLikedCommentHash() =>
    r'654413d55548546a89067c2861c82de55fb9416a';

/// See also [hasUserLikedComment].
@ProviderFor(hasUserLikedComment)
const hasUserLikedCommentProvider = HasUserLikedCommentFamily();

/// See also [hasUserLikedComment].
class HasUserLikedCommentFamily extends Family<AsyncValue<bool>> {
  /// See also [hasUserLikedComment].
  const HasUserLikedCommentFamily();

  /// See also [hasUserLikedComment].
  HasUserLikedCommentProvider call(
    String commentId,
  ) {
    return HasUserLikedCommentProvider(
      commentId,
    );
  }

  @override
  HasUserLikedCommentProvider getProviderOverride(
    covariant HasUserLikedCommentProvider provider,
  ) {
    return call(
      provider.commentId,
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
  String? get name => r'hasUserLikedCommentProvider';
}

/// See also [hasUserLikedComment].
class HasUserLikedCommentProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [hasUserLikedComment].
  HasUserLikedCommentProvider(
    String commentId,
  ) : this._internal(
          (ref) => hasUserLikedComment(
            ref as HasUserLikedCommentRef,
            commentId,
          ),
          from: hasUserLikedCommentProvider,
          name: r'hasUserLikedCommentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hasUserLikedCommentHash,
          dependencies: HasUserLikedCommentFamily._dependencies,
          allTransitiveDependencies:
              HasUserLikedCommentFamily._allTransitiveDependencies,
          commentId: commentId,
        );

  HasUserLikedCommentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.commentId,
  }) : super.internal();

  final String commentId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(HasUserLikedCommentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HasUserLikedCommentProvider._internal(
        (ref) => create(ref as HasUserLikedCommentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        commentId: commentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _HasUserLikedCommentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasUserLikedCommentProvider && other.commentId == commentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, commentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HasUserLikedCommentRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `commentId` of this provider.
  String get commentId;
}

class _HasUserLikedCommentProviderElement
    extends AutoDisposeFutureProviderElement<bool> with HasUserLikedCommentRef {
  _HasUserLikedCommentProviderElement(super.provider);

  @override
  String get commentId => (origin as HasUserLikedCommentProvider).commentId;
}

String _$videoCommentControllerHash() =>
    r'3340c71c2dbaad23f0786568a83d866890158929';

/// See also [VideoCommentController].
@ProviderFor(VideoCommentController)
final videoCommentControllerProvider =
    AutoDisposeAsyncNotifierProvider<VideoCommentController, void>.internal(
  VideoCommentController.new,
  name: r'videoCommentControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoCommentControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VideoCommentController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
