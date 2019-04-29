import 'package:flutter/material.dart';

class FadeInWidget extends StatefulWidget {
  final Widget child;

  FadeInWidget({this.child, Key key}) : super(key: key);

  @override
  _FadeInWidgetState createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  Widget build(BuildContext context) {
    return Container(
        //  color: Colors.white,
        child: FadeTransition(opacity: animation, child: widget.child));
  }
}
