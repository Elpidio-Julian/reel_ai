// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$galleryVideoServiceHash() =>
    r'9a2823e1ff5ae5867c46331221da20a99bdf0b9d';

/// See also [galleryVideoService].
@ProviderFor(galleryVideoService)
final galleryVideoServiceProvider = Provider<VideoService>.internal(
  galleryVideoService,
  name: r'galleryVideoServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$galleryVideoServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GalleryVideoServiceRef = ProviderRef<VideoService>;
String _$galleryControllerHash() => r'5a55ed4ecb283902d2106fcb94c7957a97fae9be';

/// See also [GalleryController].
@ProviderFor(GalleryController)
final galleryControllerProvider =
    AsyncNotifierProvider<GalleryController, List<Video>>.internal(
  GalleryController.new,
  name: r'galleryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$galleryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GalleryController = AsyncNotifier<List<Video>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
