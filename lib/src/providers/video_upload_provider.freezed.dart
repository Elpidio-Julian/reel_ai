// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_upload_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VideoUploadState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  File? get selectedVideo => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isUploading => throw _privateConstructorUsedError;
  double? get uploadProgress => throw _privateConstructorUsedError;

  /// Create a copy of VideoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoUploadStateCopyWith<VideoUploadState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoUploadStateCopyWith<$Res> {
  factory $VideoUploadStateCopyWith(
          VideoUploadState value, $Res Function(VideoUploadState) then) =
      _$VideoUploadStateCopyWithImpl<$Res, VideoUploadState>;
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      File? selectedVideo,
      String? description,
      bool isUploading,
      double? uploadProgress});
}

/// @nodoc
class _$VideoUploadStateCopyWithImpl<$Res, $Val extends VideoUploadState>
    implements $VideoUploadStateCopyWith<$Res> {
  _$VideoUploadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedVideo = freezed,
    Object? description = freezed,
    Object? isUploading = null,
    Object? uploadProgress = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedVideo: freezed == selectedVideo
          ? _value.selectedVideo
          : selectedVideo // ignore: cast_nullable_to_non_nullable
              as File?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isUploading: null == isUploading
          ? _value.isUploading
          : isUploading // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadProgress: freezed == uploadProgress
          ? _value.uploadProgress
          : uploadProgress // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoUploadStateImplCopyWith<$Res>
    implements $VideoUploadStateCopyWith<$Res> {
  factory _$$VideoUploadStateImplCopyWith(_$VideoUploadStateImpl value,
          $Res Function(_$VideoUploadStateImpl) then) =
      __$$VideoUploadStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      File? selectedVideo,
      String? description,
      bool isUploading,
      double? uploadProgress});
}

/// @nodoc
class __$$VideoUploadStateImplCopyWithImpl<$Res>
    extends _$VideoUploadStateCopyWithImpl<$Res, _$VideoUploadStateImpl>
    implements _$$VideoUploadStateImplCopyWith<$Res> {
  __$$VideoUploadStateImplCopyWithImpl(_$VideoUploadStateImpl _value,
      $Res Function(_$VideoUploadStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedVideo = freezed,
    Object? description = freezed,
    Object? isUploading = null,
    Object? uploadProgress = freezed,
  }) {
    return _then(_$VideoUploadStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedVideo: freezed == selectedVideo
          ? _value.selectedVideo
          : selectedVideo // ignore: cast_nullable_to_non_nullable
              as File?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isUploading: null == isUploading
          ? _value.isUploading
          : isUploading // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadProgress: freezed == uploadProgress
          ? _value.uploadProgress
          : uploadProgress // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$VideoUploadStateImpl implements _VideoUploadState {
  const _$VideoUploadStateImpl(
      {this.isLoading = false,
      this.error,
      this.selectedVideo,
      this.description,
      this.isUploading = false,
      this.uploadProgress});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final File? selectedVideo;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isUploading;
  @override
  final double? uploadProgress;

  @override
  String toString() {
    return 'VideoUploadState(isLoading: $isLoading, error: $error, selectedVideo: $selectedVideo, description: $description, isUploading: $isUploading, uploadProgress: $uploadProgress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoUploadStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedVideo, selectedVideo) ||
                other.selectedVideo == selectedVideo) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isUploading, isUploading) ||
                other.isUploading == isUploading) &&
            (identical(other.uploadProgress, uploadProgress) ||
                other.uploadProgress == uploadProgress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error, selectedVideo,
      description, isUploading, uploadProgress);

  /// Create a copy of VideoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoUploadStateImplCopyWith<_$VideoUploadStateImpl> get copyWith =>
      __$$VideoUploadStateImplCopyWithImpl<_$VideoUploadStateImpl>(
          this, _$identity);
}

abstract class _VideoUploadState implements VideoUploadState {
  const factory _VideoUploadState(
      {final bool isLoading,
      final String? error,
      final File? selectedVideo,
      final String? description,
      final bool isUploading,
      final double? uploadProgress}) = _$VideoUploadStateImpl;

  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  File? get selectedVideo;
  @override
  String? get description;
  @override
  bool get isUploading;
  @override
  double? get uploadProgress;

  /// Create a copy of VideoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoUploadStateImplCopyWith<_$VideoUploadStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
