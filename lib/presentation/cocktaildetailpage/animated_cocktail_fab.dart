import 'package:cocktail_rush/model/cocktail.dart';
import 'package:flutter/material.dart';

class AnimatedCocktailFab extends StatefulWidget {
  final Cocktail cocktail;
  final Function(Cocktail) onAddToFav;
  final Function(Cocktail) onRemoveFromFav;

  AnimatedCocktailFab({this.cocktail, this.onAddToFav, this.onRemoveFromFav});

  @override
  _AnimatedCocktailFabState createState() => _AnimatedCocktailFabState();
}

class _AnimatedCocktailFabState extends State<AnimatedCocktailFab>
    with TickerProviderStateMixin {
  AnimationController favController;
  AnimationController appearanceController;
  Animation _animation;
  Animation _appearanceAnimation;
  Icon currentIcon;
  final Icon addFavIcon = Icon(Icons.favorite);
  final Icon removeFavIcon = Icon(Icons.favorite_border);

  Future<void> _playAnimation() async {
    try {
      await favController.forward().orCancel;
      await favController.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because being disposed
    }
  }

  Future<void> _animateAppearance() async {
    try {
      await appearanceController.forward().orCancel;
    } on TickerCanceled {}
  }

  @override
  void initState() {
    super.initState();
    appearanceController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    appearanceController.addListener(() {
      setState(() {});
    });

    _appearanceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: appearanceController,
        curve: Interval(
          0.5,
          1.0,
          curve: Curves.easeIn,
        ),
      ),
    );

    _animateAppearance();

    favController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    currentIcon = widget.cocktail.isFav ? addFavIcon : removeFavIcon;
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: favController,
        curve: Interval(
          0.25,
          1.0,
          curve: Curves.linear,
        ),
      ),
    );
    favController
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.reverse) {
          currentIcon = widget.cocktail.isFav ? addFavIcon : removeFavIcon;
        }
      });
  }

  @override
  void dispose() {
    favController.dispose();
    appearanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _appearanceAnimation.value,
      child: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Transform.scale(scale: 1 - _animation.value, child: currentIcon),
        onPressed: () {
          _playAnimation();
          if (widget.cocktail.isFav) {
            widget.onRemoveFromFav(widget.cocktail);
          } else {
            widget.onAddToFav(widget.cocktail);
          }
        },
      ),
    );
  }
}
