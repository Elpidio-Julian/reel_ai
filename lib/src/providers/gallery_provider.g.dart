// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$galleryVideoServiceHash() =>
    r'f6dfb100a86bbcf0f61f02e0df8beb65c0ac4497';

/// See also [galleryVideoService].
@ProviderFor(galleryVideoService)
final galleryVideoServiceProvider = AutoDisposeProvider<VideoService>.internal(
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
typedef GalleryVideoServiceRef = AutoDisposeProviderRef<VideoService>;
String _$galleryControllerHash() => r'fb6b276134c94d4829f475bca91553ec21eccd88';

/// See also [GalleryController].
@ProviderFor(GalleryController)
final galleryControllerProvider =
    AutoDisposeAsyncNotifierProvider<GalleryController, List<Video>>.internal(
  GalleryController.new,
  name: r'galleryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$galleryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GalleryController = AutoDisposeAsyncNotifier<List<Video>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
