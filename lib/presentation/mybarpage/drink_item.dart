import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/firestoredimage/firestored_image.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/model/generic.dart';
import 'package:cocktail_rush/presentation/widgets/circle_border_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class DrinkFilterItem extends StatefulWidget {
  final Drink drink;
  final GestureTapCallback onTap;
  final double width;

  const DrinkFilterItem(
      {Key key,
      @required this.drink,
      @required this.onTap,
      @required this.width})
      : super(key: key);

  @override
  DrinkFilterItemState createState() {
    return new DrinkFilterItemState();
  }
}

class DrinkFilterItemState extends State<DrinkFilterItem>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _reverseController;
  Selectable _currentSelectable;

  final Icon inBarIndicator = Icon(
    Icons.local_bar,
    color: Colors.purple,
    size: 23,
  );

  @override
  void initState() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _reverseController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);

    _currentSelectable = SelectableImpl.copy(widget.drink.isSelected());

    _controller
      ..addListener(() {
        setState(() {});
      });

    _reverseController
      ..addListener(() {
        setState(() {});
      });

    _currentSelectable.isSelected()
        ? _controller.value = 1.0
        : _reverseController.value = 1.0;

    super.initState();
  }

  @override
  void didUpdateWidget(DrinkFilterItem oldWidget) {
    if (_currentSelectable != null &&
        widget.drink.isSelected() != _currentSelectable.isSelected()) {
      _playAnimation(widget.drink.isSelected());
    }
    _currentSelectable = SelectableImpl.copy(widget.drink.isSelected());
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _reverseController.dispose();
    super.dispose();
  }

  Future<void> _playAnimation(bool inBar) async {
    try {
      if (inBar) {
        await _controller.forward(from: 0.0).orCancel;
      } else {
        await _reverseController.forward(from: 0.0).orCancel;
      }
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        converter: (store) => _ViewModel.fromStore(store, widget.drink),
        builder: (context, vm) {
          return GestureDetector(
            onTap: widget.onTap,
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: CircleBorderImage(
                  imageUrl: widget.drink.image,
                  diameter: widget.width,
                  borderColor: Colors.pink,
                  padding: 12.0,
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Transform.scale(
                    scale: _calculateScale(), child: inBarIndicator),
              ),
            ]),
          );
        });
  }

  double _calculateScale() {
    if (widget.drink.isSelected()) {
      return _controller.value;
    } else {
      return 1 - _reverseController.value;
    }
  }
}

class DrinkBarItem extends StatefulWidget {
  final Drink drink;
  final GestureTapCallback onTap;
  final Animation<double> animation;

  const DrinkBarItem(
      {Key key,
      @required this.drink,
      @required this.animation,
      @required this.onTap})
      : super(key: key);

  @override
  DrinkItemState createState() {
    return new DrinkItemState();
  }
}

class DrinkItemState extends State<DrinkBarItem> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store, widget.drink),
      builder: (context, vm) {
        return SizeTransition(
          axis: Axis.vertical,
          sizeFactor: widget.animation,
          child: Card(
              elevation: 0.0,
              child: ListTile(
                contentPadding: const EdgeInsets.all(24.0),
                onTap: widget.onTap,
                leading: FireStoredImage.inBarListItem(70, widget.drink.image),
                title: Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Row(children: <Widget>[
                      Expanded(
                        flex: 9,
                        child: Text(
                          widget.drink.name,
                          style: TextStyle(
                              color: Colors.purple[900],
                              fontWeight: FontWeight.normal,
                              fontSize: 20.0),
                        ),
                      ),
                    ])),
                subtitle: Text(
                  widget.drink.usedInNumberOfCocktails(context),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.purple[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                ),
                trailing: IconButton(
                    iconSize: 50.0,
                    color: Colors.pink,
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      vm.store.dispatch(
                          UpdateBarInStorageAction(widget.drink, false));
                    }),
              )),
        );
      },
    );
  }
}

class _ViewModel {
  bool isInBar;
  Store<AppState> store;

  _ViewModel(this.isInBar, this.store);

  static _ViewModel fromStore(Store<AppState> store, Drink drink) {
    Drink d = store.state.content.drinks.firstWhere((d) => d == drink);
    return _ViewModel(d.inBar, store);
  }
}
