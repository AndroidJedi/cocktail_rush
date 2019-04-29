import 'package:cocktail_rush/model/generic.dart';
import 'package:flutter/material.dart';

class SnackNotifierWidget<Item extends Selectable> extends StatefulWidget {
  final Widget child;
  final Item item;
  final Function() getActionText;
  final Function() onAnimationCompleted;

  SnackNotifierWidget(
      {Key key,
      this.child,
      this.item,
      this.getActionText,
      this.onAnimationCompleted})
      : super(key: key);

  @override
  SnackNotifierWidgetState createState() => SnackNotifierWidgetState();
}

class SnackNotifierWidgetState extends State<SnackNotifierWidget>
    with SingleTickerProviderStateMixin {
  Animation _animation;
  Selectable _currentSelectable;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 750), vsync: this);
    _currentSelectable = SelectableImpl.copy(widget.item.isSelected());
    _animation = Tween<double>(
      begin: 0,
      end: 36.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          0.8,
          curve: Curves.easeOut,
        ),
      ),
    );
    _controller
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (widget.onAnimationCompleted != null) {
            widget.onAnimationCompleted();
          }
        }
      });
  }

  Future<void> _playAnimation() async {
    try {
      await _controller.forward().orCancel;
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  void didUpdateWidget(SnackNotifierWidget oldWidget) {
    if (_currentSelectable != null &&
        widget.item.isSelected() != _currentSelectable.isSelected()) {
      _playAnimation();
    }
    _currentSelectable = SelectableImpl.copy(widget.item.isSelected());
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
                height: MediaQuery.of(context).size.height - _animation.value,
                child: widget.child),
          ),
          Container(
              height: _animation.value,
              width: double.infinity,
              color: Colors.purple,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${widget.getActionText()}",
                        style: Theme.of(context).textTheme.title)
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
