// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_upload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoServiceHash() => r'0821dd5f8797655c91537c3aef15c182a7f7b958';

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
    r'4bf87611004d3fab51eebbbf3408dd3d38c8cf5e';

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
