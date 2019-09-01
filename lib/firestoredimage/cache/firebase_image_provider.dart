import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:cocktail_rush/firestoredimage/cache/firebase_image_cache_manager.dart';
import 'package:cocktail_rush/firestoredimage/cache/firebase_image_url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui show instantiateImageCodec, Codec;

class FireBaseImageProvider extends ImageProvider<FireBaseImageProvider> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  const FireBaseImageProvider(this.url, {this.scale = 1.0})
      : assert(url != null),
        assert(scale != null);

  /// The URL from which the image will be fetched.
  // final StorageReference url;
  final FireBaseUrl url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<FireBaseImageProvider> obtainKey(ImageConfiguration configuration) {
    return new SynchronousFuture<FireBaseImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(FireBaseImageProvider key) {
    return new MultiFrameImageStreamCompleter(
        codec: _loadAsync(key),
        scale: key.scale,
        informationCollector: () => List<DiagnosticsNode>());
  }

  static Map<ImageConfigurationKey, ImageInfo> _imageInfoCache =
      HashMap<ImageConfigurationKey, ImageInfo>();

  @override
  ImageStream resolve(ImageConfiguration configuration) {
    if (_imageInfoCache
        .containsKey(ImageConfigurationKey(configuration, url.image))) {
      ImageInfo imageInfo =
          _imageInfoCache[ImageConfigurationKey(configuration, url.image)];
      final ImageStream stream = ImageStream();
      ImageStreamCompleter imageStreamCompleter =
          new OneFrameImageStreamCompleter(
              SynchronousFuture<ImageInfo>(imageInfo));
      stream.setCompleter(PaintingBinding.instance.imageCache
          .putIfAbsent(obtainKey(configuration), () => imageStreamCompleter));
      return stream;
    }

    ImageStream imageStream = super.resolve(configuration);

    imageStream.addListener(ImageStreamListener((imageInfo, syncCall) {
      return _imageInfoCache.putIfAbsent(
          ImageConfigurationKey(configuration, url.image), () => imageInfo);
    }));

    return imageStream;
  }

  ///
  ///
  ///  CREATES OVERHEAD
  ///
  ///

  Future<ui.Codec> _loadAsync(FireBaseImageProvider key) async {
    var cacheManager = await FirebaseCacheManager.getInstance();
    var file = await cacheManager.getFile(url);
    if (file == null) {
      // if (errorListener != null) errorListener();
      cacheManager.removeFromCache(url);
      throw new Exception("Couldn't download or retreive file.");
    }
    return await _loadAsyncFromFile(key, file, cacheManager);
  }

  ///
  ///
  ///  CREATES OVERHEAD
  ///
  ///

  Future<ui.Codec> _loadAsyncFromFile(FireBaseImageProvider key, File file,
      FirebaseCacheManager cacheManager) async {
    assert(key == this);

    final Uint8List bytes = await file.readAsBytes();

    if (bytes.lengthInBytes == 0) {
      //  if (errorListener != null) errorListener();
      cacheManager.removeFromCache(url);
      throw new Exception("File was empty");
    }

    return await ui.instantiateImageCodec(bytes);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final FireBaseImageProvider typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}

class ImageConfigurationKey {
  ImageConfiguration configuration;
  String image;

  ImageConfigurationKey(this.configuration, this.image);

  @override
  bool operator ==(other) {
    if (!(other is ImageConfigurationKey)) {
      return false;
    }
    ImageConfigurationKey otherImageConfigurationKey = other;
    return this.configuration == otherImageConfigurationKey.configuration &&
        this.image == otherImageConfigurationKey.image;
  }

  @override
  int get hashCode => configuration.hashCode ^ image.hashCode;
}
