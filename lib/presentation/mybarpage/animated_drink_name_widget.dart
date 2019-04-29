import 'package:flutter/material.dart';

class AnimatedDrinkNameWidget extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.0, end: 1);

  final String drinkName;

  AnimatedDrinkNameWidget({Key key, this.drinkName, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Opacity(
        opacity: _opacityTween.evaluate(animation),
        child: Text(
          drinkName,
          style: TextStyle(
              color: Colors.purple,  fontSize: 20.0),
        ),
      ),
    );
  }
}