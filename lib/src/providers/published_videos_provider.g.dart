// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'published_videos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$publishedVideoServiceHash() =>
    r'ba074f4de31f135c76bc6bc0d93557e04facda1e';

/// See also [publishedVideoService].
@ProviderFor(publishedVideoService)
final publishedVideoServiceProvider = Provider<VideoService>.internal(
  publishedVideoService,
  name: r'publishedVideoServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$publishedVideoServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PublishedVideoServiceRef = ProviderRef<VideoService>;
String _$publishedVideosControllerHash() =>
    r'4add8d56917856858b0966220bede259bf338234';

/// See also [PublishedVideosController].
@ProviderFor(PublishedVideosController)
final publishedVideosControllerProvider =
    AsyncNotifierProvider<PublishedVideosController, List<Video>>.internal(
  PublishedVideosController.new,
  name: r'publishedVideosControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$publishedVideosControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PublishedVideosController = AsyncNotifier<List<Video>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
