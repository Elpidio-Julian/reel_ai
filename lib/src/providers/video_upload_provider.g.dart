// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_upload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoServiceHash() => r'fcb5d658bcc45f979036d1b2cb92e4665672e13f';

/// See also [videoService].
@ProviderFor(videoService)
final videoServiceProvider = Provider<VideoService>.internal(
  videoService,
  name: r'videoServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$videoServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideoServiceRef = ProviderRef<VideoService>;
String _$videoUploadControllerHash() =>
    r'b843d82f9c975e9a80ac19f3be2cd75f8638ca5d';

/// See also [VideoUploadController].
@ProviderFor(VideoUploadController)
final videoUploadControllerProvider =
    NotifierProvider<VideoUploadController, VideoUploadState>.internal(
  VideoUploadController.new,
  name: r'videoUploadControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoUploadControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VideoUploadController = Notifier<VideoUploadState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
