// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_interaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoInteractionRepositoryHash() =>
    r'4be5a17ca36160c8283d4a096de5fe607da6c35e';

/// See also [videoInteractionRepository].
@ProviderFor(videoInteractionRepository)
final videoInteractionRepositoryProvider =
    Provider<VideoInteractionRepository>.internal(
  videoInteractionRepository,
  name: r'videoInteractionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoInteractionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideoInteractionRepositoryRef = ProviderRef<VideoInteractionRepository>;
String _$hasUserInteractionHash() =>
    r'0059eb94bd6bf8261c65d3f9230947f7ab868841';

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

/// See also [hasUserInteraction].
@ProviderFor(hasUserInteraction)
const hasUserInteractionProvider = HasUserInteractionFamily();

/// See also [hasUserInteraction].
class HasUserInteractionFamily extends Family<AsyncValue<bool>> {
  /// See also [hasUserInteraction].
  const HasUserInteractionFamily();

  /// See also [hasUserInteraction].
  HasUserInteractionProvider call(
    String videoId,
    String type,
  ) {
    return HasUserInteractionProvider(
      videoId,
      type,
    );
  }

  @override
  HasUserInteractionProvider getProviderOverride(
    covariant HasUserInteractionProvider provider,
  ) {
    return call(
      provider.videoId,
      provider.type,
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
  String? get name => r'hasUserInteractionProvider';
}

/// See also [hasUserInteraction].
class HasUserInteractionProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [hasUserInteraction].
  HasUserInteractionProvider(
    String videoId,
    String type,
  ) : this._internal(
          (ref) => hasUserInteraction(
            ref as HasUserInteractionRef,
            videoId,
            type,
          ),
          from: hasUserInteractionProvider,
          name: r'hasUserInteractionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hasUserInteractionHash,
          dependencies: HasUserInteractionFamily._dependencies,
          allTransitiveDependencies:
              HasUserInteractionFamily._allTransitiveDependencies,
          videoId: videoId,
          type: type,
        );

  HasUserInteractionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoId,
    required this.type,
  }) : super.internal();

  final String videoId;
  final String type;

  @override
  Override overrideWith(
    FutureOr<bool> Function(HasUserInteractionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HasUserInteractionProvider._internal(
        (ref) => create(ref as HasUserInteractionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoId: videoId,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _HasUserInteractionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasUserInteractionProvider &&
        other.videoId == videoId &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoId.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HasUserInteractionRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `videoId` of this provider.
  String get videoId;

  /// The parameter `type` of this provider.
  String get type;
}

class _HasUserInteractionProviderElement
    extends AutoDisposeFutureProviderElement<bool> with HasUserInteractionRef {
  _HasUserInteractionProviderElement(super.provider);

  @override
  String get videoId => (origin as HasUserInteractionProvider).videoId;
  @override
  String get type => (origin as HasUserInteractionProvider).type;
}

String _$videoStatsHash() => r'8c5af541395d3d4513e220330134f9f97b129327';

/// See also [videoStats].
@ProviderFor(videoStats)
const videoStatsProvider = VideoStatsFamily();

/// See also [videoStats].
class VideoStatsFamily extends Family<AsyncValue<VideoStats?>> {
  /// See also [videoStats].
  const VideoStatsFamily();

  /// See also [videoStats].
  VideoStatsProvider call(
    String videoId,
  ) {
    return VideoStatsProvider(
      videoId,
    );
  }

  @override
  VideoStatsProvider getProviderOverride(
    covariant VideoStatsProvider provider,
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
  String? get name => r'videoStatsProvider';
}

/// See also [videoStats].
class VideoStatsProvider extends AutoDisposeStreamProvider<VideoStats?> {
  /// See also [videoStats].
  VideoStatsProvider(
    String videoId,
  ) : this._internal(
          (ref) => videoStats(
            ref as VideoStatsRef,
            videoId,
          ),
          from: videoStatsProvider,
          name: r'videoStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoStatsHash,
          dependencies: VideoStatsFamily._dependencies,
          allTransitiveDependencies:
              VideoStatsFamily._allTransitiveDependencies,
          videoId: videoId,
        );

  VideoStatsProvider._internal(
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
    Stream<VideoStats?> Function(VideoStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VideoStatsProvider._internal(
        (ref) => create(ref as VideoStatsRef),
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
  AutoDisposeStreamProviderElement<VideoStats?> createElement() {
    return _VideoStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoStatsProvider && other.videoId == videoId;
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
mixin VideoStatsRef on AutoDisposeStreamProviderRef<VideoStats?> {
  /// The parameter `videoId` of this provider.
  String get videoId;
}

class _VideoStatsProviderElement
    extends AutoDisposeStreamProviderElement<VideoStats?> with VideoStatsRef {
  _VideoStatsProviderElement(super.provider);

  @override
  String get videoId => (origin as VideoStatsProvider).videoId;
}

String _$userVideoInteractionsHash() =>
    r'fdb696728421e0a5ea26a622bb333ca0ad0d1c68';

/// See also [userVideoInteractions].
@ProviderFor(userVideoInteractions)
const userVideoInteractionsProvider = UserVideoInteractionsFamily();

/// See also [userVideoInteractions].
class UserVideoInteractionsFamily
    extends Family<AsyncValue<List<VideoInteraction>>> {
  /// See also [userVideoInteractions].
  const UserVideoInteractionsFamily();

  /// See also [userVideoInteractions].
  UserVideoInteractionsProvider call(
    String videoId,
  ) {
    return UserVideoInteractionsProvider(
      videoId,
    );
  }

  @override
  UserVideoInteractionsProvider getProviderOverride(
    covariant UserVideoInteractionsProvider provider,
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
  String? get name => r'userVideoInteractionsProvider';
}

/// See also [userVideoInteractions].
class UserVideoInteractionsProvider
    extends AutoDisposeFutureProvider<List<VideoInteraction>> {
  /// See also [userVideoInteractions].
  UserVideoInteractionsProvider(
    String videoId,
  ) : this._internal(
          (ref) => userVideoInteractions(
            ref as UserVideoInteractionsRef,
            videoId,
          ),
          from: userVideoInteractionsProvider,
          name: r'userVideoInteractionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userVideoInteractionsHash,
          dependencies: UserVideoInteractionsFamily._dependencies,
          allTransitiveDependencies:
              UserVideoInteractionsFamily._allTransitiveDependencies,
          videoId: videoId,
        );

  UserVideoInteractionsProvider._internal(
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
    FutureOr<List<VideoInteraction>> Function(UserVideoInteractionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserVideoInteractionsProvider._internal(
        (ref) => create(ref as UserVideoInteractionsRef),
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
  AutoDisposeFutureProviderElement<List<VideoInteraction>> createElement() {
    return _UserVideoInteractionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserVideoInteractionsProvider && other.videoId == videoId;
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
mixin UserVideoInteractionsRef
    on AutoDisposeFutureProviderRef<List<VideoInteraction>> {
  /// The parameter `videoId` of this provider.
  String get videoId;
}

class _UserVideoInteractionsProviderElement
    extends AutoDisposeFutureProviderElement<List<VideoInteraction>>
    with UserVideoInteractionsRef {
  _UserVideoInteractionsProviderElement(super.provider);

  @override
  String get videoId => (origin as UserVideoInteractionsProvider).videoId;
}

String _$videoInteractionControllerHash() =>
    r'490c95eadbc837b501d452c61fe138c9899e8cb4';

/// See also [VideoInteractionController].
@ProviderFor(VideoInteractionController)
final videoInteractionControllerProvider =
    AsyncNotifierProvider<VideoInteractionController, void>.internal(
  VideoInteractionController.new,
  name: r'videoInteractionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoInteractionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VideoInteractionController = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
