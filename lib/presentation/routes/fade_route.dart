import 'package:flutter/material.dart';

class FadeRoute<T> extends MaterialPageRoute<T> {
  Duration duration;

  FadeRoute({WidgetBuilder builder, RouteSettings settings, this.duration = const Duration(milliseconds: 0)})
      : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute) return child;
    return new Opacity(opacity: animation.value, child: child);
    //  return new FadeTransition(opacity: animation, child: child);
  }
}
