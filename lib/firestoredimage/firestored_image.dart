import 'package:cocktail_rush/firestoredimage/cache/firebase_image_provider.dart';
import 'package:cocktail_rush/firestoredimage/cache/firebase_image_url.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FireStoredImage extends StatefulWidget {
  static const double imageSize = 70.0;

  /// The duration of the fade-out animation for the [placeholder].
  final Duration fadeOutDuration;

  /// The curve of the fade-out animation for the [placeholder].
  final Curve fadeOutCurve;

  /// The duration of the fade-in animation for the [imageUrl].
  final Duration fadeInDuration;

  /// The curve of the fade-in animation for the [imageUrl].
  final Curve fadeInCurve;

  final double width;

  final double height;

  final ImageProvider imageProvider;
  final Widget placeholder;
  final Widget errorWidget;

  const FireStoredImage({
    Key key,
    @required this.imageProvider,
    @required this.placeholder,
    @required this.errorWidget,
    @required this.width,
    @required this.height,
    this.fadeOutDuration: const Duration(milliseconds: 500),
    this.fadeOutCurve: Curves.easeOut,
    this.fadeInDuration: const Duration(milliseconds: 700),
    this.fadeInCurve: Curves.easeIn,
  })  : assert(imageProvider != null),
        super(key: key);

  FireStoredImage.inBarListItem(double size, String image)
      : width = size,
        height = size,
        placeholder = Icon(Icons.image, size: size, color: Colors.pink[50]),
        errorWidget = Icon(Icons.error, size: size, color: Colors.pink[50]),
        imageProvider = FireBaseImageProvider(FireBaseUrl(
            nodes: List<String>()..add("cocktails")..add("big"), image: image)),
        fadeOutDuration = const Duration(milliseconds: 300),
        fadeOutCurve = Curves.easeOut,
        fadeInDuration = const Duration(milliseconds: 700),
        fadeInCurve = Curves.easeIn;

  @override
  _FireStoredImageState createState() => _FireStoredImageState();
}

typedef void ErrorListener();

class _FireStoredImageState extends State<FireStoredImage>
    with TickerProviderStateMixin {
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  ImageStreamListener _updateImageListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We call _getImage here because createLocalImageConfiguration() needs to
    // be called again if the dependencies changed, in case the changes relate
    // to the DefaultAssetBundle, MediaQuery, etc, which that method uses.
    _getImage();
  }

  @override
  void didUpdateWidget(FireStoredImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) _getImage();
  }

  @override
  void reassemble() {
    _getImage();
    super.reassemble();
  }

  void _getImage() {
    final ImageStream oldImageStream = _imageStream;
    _imageStream =
        widget.imageProvider.resolve(createLocalImageConfiguration(context));
    if (_imageStream.key != oldImageStream?.key) {
      // If the keys are the same, then we got the same image back, and so we don't
      // need to update the listeners. If the key changed, though, we must make sure
      // to switch our listeners to the new image stream.
      oldImageStream?.removeListener(_updateImageListener);
      _imageStream.addListener(_updateImageListener);
    }

    if (_phase == Phase.start) _updatePhase();
  }

  void _imageLoadingFailed() {
    _hasError = true;
    _updatePhase();
  }

  bool _hasError;

  void _updatePhase() {
    setState(() {
      switch (_phase) {
        case Phase.start:
          if (_imageInfo != null || _hasError)
            _phase = Phase.completed;
          else
            _phase = Phase.waiting;
          break;
        case Phase.waiting:
          if (_hasError) {
            _phase = Phase.completed;
            return;
          }

          if (_imageInfo != null || _hasError) {
            if (widget.placeholder == null) {
              _startFadeIn();
            } else {
              _startFadeOut();
            }
          }
          break;
        case Phase.fadeOut:
          if (_controller.status == AnimationStatus.dismissed) {
            _startFadeIn();
          }
          break;
        case Phase.fadeIn:
          if (_controller.status == AnimationStatus.completed) {
            // Done finding in new image.
            _phase = Phase.completed;
          }
          break;
        case Phase.completed:
          // Nothing to do.
          break;
      }
    });
  }

  // Received image data. Begin placeholder fade-out.
  void _startFadeOut() {
    _controller.duration = widget.fadeOutDuration;
    _animation = new CurvedAnimation(
      parent: _controller,
      curve: widget.fadeOutCurve,
    );
    _phase = Phase.fadeOut;
    _controller.reverse(from: 1.0);
  }

  // Done fading out placeholder. Begin target image fade-in.
  void _startFadeIn() {
    _controller.duration = widget.fadeInDuration;
    _animation = new CurvedAnimation(
      parent: _controller,
      curve: widget.fadeInCurve,
    );
    _phase = Phase.fadeIn;
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _imageStream.removeListener(_updateImageListener);
    super.dispose();
  }

  @override
  void initState() {
    _hasError = false;
    _updateImageListener = ImageStreamListener((imageInfo, synchronousCall) {
      setState(() {
        _imageInfo = imageInfo;
        _updatePhase();
      });
    }, onError: (exception, stackTrace) {
      _imageLoadingFailed();
    });
    _controller = new AnimationController(
      value: 1.0,
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {
        // Trigger rebuild to update opacity value.
      });
    });
    _controller.addStatusListener((AnimationStatus status) {
      _updatePhase();
    });

    super.initState();
  }

  bool get _isShowingPlaceholder {
    assert(_phase != null);
    switch (_phase) {
      case Phase.start:
      case Phase.waiting:
      case Phase.fadeOut:
        return true;
      case Phase.fadeIn:
      case Phase.completed:
        return _hasError /* && widget.errorWidget == null*/;
        return false;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    // assert(_phase != Phase.start);

    if (_hasError && widget.errorWidget != null) {
      return _fadedWidget(widget.errorWidget);
    }

    if (_isShowingPlaceholder && widget.placeholder != null) {
      return _fadedWidget(widget.placeholder);
    }

    return new RawImage(
      image: _imageInfo?.image, // this is a dart:ui Image object
      scale: _imageInfo?.scale ?? 1.0,
      width: widget.width,
      height: widget.height,
    );
  }

  AnimationController _controller;
  Animation<double> _animation;

  Phase _phase = Phase.start;

  Widget _fadedWidget(Widget w) {
    return new Opacity(
      opacity: _animation?.value ?? 1.0,
      child: w,
    );
  }
}

enum Phase {
  /// The initial state.
  ///
  /// We do not yet know whether the target image is ready and therefore no
  /// animation is necessary, or whether we need to use the placeholder and
  /// wait for the image to load.
  start,

  /// Waiting for the target image to load.
  waiting,

  /// Fading out previous image.
  fadeOut,

  /// Fading in new image.
  fadeIn,

  /// Fade-in complete.
  completed,
}
