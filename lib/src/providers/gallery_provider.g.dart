// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$galleryVideoServiceHash() =>
    r'18ab2333bfa164bbcc0021bfe2d4b16f57d8ca06';

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
String _$galleryControllerHash() => r'892b4341f183b57ed1be4694722e40a079321d8a';

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
