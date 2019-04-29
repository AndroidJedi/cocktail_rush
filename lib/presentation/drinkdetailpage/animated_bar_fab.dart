import 'package:cocktail_rush/model/drink.dart';
import 'package:flutter/material.dart';

class AnimatedBarFab extends StatefulWidget {
  final Drink drink;
  final Function(Drink) onAddToBar;
  final Function(Drink) onRemoveFromBar;

  AnimatedBarFab({this.drink, this.onAddToBar, this.onRemoveFromBar});

  @override
  _AnimatedBarFabState createState() => _AnimatedBarFabState();
}

class _AnimatedBarFabState extends State<AnimatedBarFab>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation _animation;
  Icon currentIcon;
  final Icon addIcon = Icon(Icons.add, color: Colors.white);
  final Icon removeIcon = Icon(Icons.remove, color: Colors.white);

  Future<void> _playAnimation() async {
    try {
      await controller.forward().orCancel;
      await controller.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    currentIcon = widget.drink.inBar ? removeIcon : addIcon;
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.25,
          1.0,
          curve: Curves.linear,
        ),
      ),
    );
    controller
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.reverse) {
          currentIcon = widget.drink.inBar ? removeIcon : addIcon;
        }
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.purple,
      child: Transform.scale(scale: 1 - _animation.value, child: currentIcon),
      onPressed: () {
        _playAnimation();
        if (widget.drink.inBar) {
          widget.onRemoveFromBar(widget.drink);
        } else {
          widget.onAddToBar(widget.drink);
        }
      },
    );
  }
}
