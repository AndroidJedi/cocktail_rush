import 'dart:async';
import 'dart:math';
import 'package:audioplayer/audioplayer.dart';
import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/presentation/cocktaildetailpage/cocktail_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:sensors/sensors.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vibrate/vibrate.dart';

class ShakerPage extends StatelessWidget {
  final bool foreground;

  ShakerPage({this.foreground});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        converter: (store) => _ViewModel.fromStore(store.state),
        builder: (context, vm) {
          return Column(children: [
            Flexible(child: AnimatedShaker(
                foreground: foreground,
                onAnimationFinished: () {
                  Navigator.of(context).push(MaterialPageRoute<ShakerPage>(
                    builder: (_) =>
                        CocktailDetailPage(
                          cocktail: vm.randomCocktail,
                          hero: false,
                        ),
                  ));
                }), flex: 7),
            Flexible(child: Text(
                CrLocalization.of(context).shakePageHint,
                style: new TextStyle(
                  color: const Color(0x88444444),
                  fontSize: 24.0,
                  fontFamily: 'mermaid',
                )
            ), flex: 2)
          ]);
        });
  }
}

class AnimatedShaker extends StatefulWidget {
  final OnAnimationFinished onAnimationFinished;
  bool foreground = false;

  AnimatedShaker({this.foreground, this.onAnimationFinished});

  @override
  AnimatedShakerState createState() {
    return new AnimatedShakerState();
  }
}

class _ViewModel {
  var _rnd = new Random();
  List<Cocktail> _cocktails;

  get randomCocktail {
    return _cocktails[_rnd.nextInt(_cocktails.length - 1)];
  }

  _ViewModel.fromStore(AppState state) {
    _cocktails = state.content.cocktails;
  }
}

class AnimatedShakerState extends State<AnimatedShaker>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  double currentTransition = 0;
  int repeatCount = 0;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];

  AudioPlayer audioPlayer = new AudioPlayer();

  ShakerNavigatorObserver _navigatorObserver;

  Future playLocal(localFileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = new File("${dir.path}/$localFileName");
    if (!(await file.exists())) {
      final soundData = await rootBundle.load("assets/$localFileName");
      final bytes = soundData.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    await audioPlayer.play(file.path, isLocal: true);
  }

  final Iterable<Duration> _pauses = [
    const Duration(milliseconds: 150),
    const Duration(milliseconds: 250),
    const Duration(milliseconds: 150),
  ];

  @override
  void initState() {
    _navigatorObserver = ShakerNavigatorObserver(
        onCocktailSelected: _cancelAccelerometerAndSoundSubscriptions,
        onShakerPopped: _initAllSubscriptions);

    Navigator
        .of(context)
        .widget
        .observers
        .add(_navigatorObserver);

    _animationController = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    final Animation transition =
    CurvedAnimation(parent: _animationController, curve: ShakeCurve());
    transition
      ..addListener(() {
        setState(() {
          currentTransition = transition.value;
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (repeatCount > 3) {
          _animationController.stop();
          audioPlayer.stop();
          widget.onAnimationFinished();
          setState(() {
            currentTransition = 0;
            repeatCount = 0;
          });
        } else if (status == AnimationStatus.completed) {
          _animationController.reverse();
          repeatCount++;
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });

    super.initState();
  }

  void _initAllSubscriptions() {
    if (_streamSubscriptions.isNotEmpty) {
      return;
    }
    _streamSubscriptions..add(
        accelerometerEvents.listen((AccelerometerEvent event) {
          final x = event.x;
          final y = event.y;
          final z = event.z;

          final accelerationSquareRoot = (x * x + y * y + z * z) / (9.8 * 9.8);
          if (accelerationSquareRoot >= 1.3 &&
              !_animationController.isAnimating) {
            playLocal("shaker_sound.mp3");
            Vibrate.vibrateWithPauses(_pauses);

            _animationController.forward();
          }
        }))..add(audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.COMPLETED) {
        if (_animationController.isAnimating) {
          playLocal("shaker_sound.mp3");
        }
      }
    }));
  }

  void _cancelAccelerometerAndSoundSubscriptions() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
  }

  @override
  void dispose() {
    _cancelAccelerometerAndSoundSubscriptions();
    _animationController.dispose();
    Navigator
        .of(context)
        .widget
        .observers
        .remove(_navigatorObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        transform: new Matrix4.translationValues(
          15 - 15 * (1 - currentTransition),
          0.0,
          0.0,
        ),
        child: Container(
          constraints: BoxConstraints.tightFor(width: 300.0, height: 450.0),
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/shaker5.png'),
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedShaker oldWidget) {
    if (oldWidget.foreground != widget.foreground) {
      if (widget.foreground) {
        _initAllSubscriptions();
      } else {
        _cancelAccelerometerAndSoundSubscriptions();
      }
    }

    super.didUpdateWidget(oldWidget);
  }
}

class ShakerNavigatorObserver extends NavigatorObserver {
  Function onShakerPopped;
  Function onCocktailSelected;

  ShakerNavigatorObserver({this.onCocktailSelected, this.onShakerPopped});

  @override
  void didPop(Route route, Route previousRoute) {
    //resubscribe
    if (route is MaterialPageRoute<ShakerPage>) {
      onShakerPopped();
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route previousRoute) {
    if (route is MaterialPageRoute<ShakerPage>) {
      //unsubscribe
      onCocktailSelected();
    }
    super.didPush(route, previousRoute);
  }
}

class ShakeCurve extends Curve {
  @override
  double transform(double t) {
    final result = sin(t * pi * 2);
    return result;
  }
}

typedef OnAnimationFinished = Function();
