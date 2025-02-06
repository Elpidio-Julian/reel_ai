// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_upload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoServiceHash() => r'203d2af87acf646de33e702e7563eb5cd3aa5f4b';

/// See also [videoService].
@ProviderFor(videoService)
final videoServiceProvider = AutoDisposeProvider<VideoService>.internal(
  videoService,
  name: r'videoServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$videoServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideoServiceRef = AutoDisposeProviderRef<VideoService>;
String _$videoPlayerControllerNotifierHash() =>
    r'3d64bc19776844bba72dc71805652c1d017432fc';

/// See also [VideoPlayerControllerNotifier].
@ProviderFor(VideoPlayerControllerNotifier)
final videoPlayerControllerNotifierProvider = AutoDisposeAsyncNotifierProvider<
    VideoPlayerControllerNotifier, VideoPlayerController?>.internal(
  VideoPlayerControllerNotifier.new,
  name: r'videoPlayerControllerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoPlayerControllerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VideoPlayerControllerNotifier
    = AutoDisposeAsyncNotifier<VideoPlayerController?>;
String _$videoUploadControllerHash() =>
    r'7a97ead0c1047d6fdd208e881e096c259e011b2f';

/// See also [VideoUploadController].
@ProviderFor(VideoUploadController)
final videoUploadControllerProvider = AutoDisposeNotifierProvider<
    VideoUploadController, VideoUploadState>.internal(
  VideoUploadController.new,
  name: r'videoUploadControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoUploadControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VideoUploadController = AutoDisposeNotifier<VideoUploadState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
