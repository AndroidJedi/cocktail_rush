import 'package:cocktail_rush/keys/keys.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/model/utils.dart';
import 'package:cocktail_rush/presentation/mybarpage/drink_item.dart';
import 'package:flutter/material.dart';

class PullUpListView extends StatefulWidget {
  final List<Drink> drinkList;
  final Function(int selectedPosition) onPullUpComplete;
  final Function(int selectedPosition) onItemTaped;
  final VoidCallback onScrollStarted;

  PullUpListView(
      {this.drinkList,
      this.onScrollStarted,
      this.onPullUpComplete,
      this.onItemTaped});

  @override
  _PullUpListViewState createState() => _PullUpListViewState();
}

List<ListItem> configListItems(List<Drink> data) {
  final List<ListItem> drinkList = List();
  drinkList
    ..add(SpaceItem())
    ..add(SpaceItem())
    ..addAll(data.map((drink) => DrinkListItem(drink)))
    ..add(SpaceItem())
    ..add(SpaceItem());
  return drinkList;
}

class _PullUpListViewState extends State<PullUpListView> {
  bool isListScrolling = false;
  var upScrolling = false;
  var scrolledPixels = 0.0;
  ScrollController controller;

  var selectedPosition = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.drinkList.length == 0) {
      return Container(
        height: 84.0,
        width: double.infinity,
      );
    } else {
      return _buildListView(configListItems(widget.drinkList), context);
    }
  }

  @override
  void initState() {
    controller = new ScrollController()
      ..addListener(() {
        if ((scrolledPixels - controller.position.pixels).abs() > 15 &&
            !isListScrolling) {
          widget.onScrollStarted();
          isListScrolling = true;
        }
      });
    super.initState();
  }

  @override
  void didUpdateWidget(PullUpListView oldWidget) {
    if (!deepEquals(widget.drinkList, _currentDrinkList)) {
      _currentDrinkList.clear();
      _currentDrinkList.addAll(widget.drinkList);
      if( widget.drinkList.length == 0){
        return;
      }
      if (selectedPosition > widget.drinkList.length - 1) {
        selectedPosition = 0;
        notifySelectedPositionChanged(selectedPosition);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  List<Drink> _currentDrinkList = List();

  void notifySelectedPositionChanged(int selectedPosition) async {
    widget.onItemTaped(selectedPosition);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildListView(List<ListItem> drinkList, BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var itemWidthWithPadding = screenWidth / 5;

    const padding = 2.0;

    return NotificationListener(
      onNotification: (Notification notification) {
        if (notification is ScrollEndNotification) {
          if (upScrolling) {
            return;
          }
          if (!isListScrolling) {
            return;
          }
          _upScroll(itemWidthWithPadding);
        }
      },
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        key: Keys.ingredientList,
        controller: controller,
        itemCount: drinkList == null ? 0 : drinkList.length,
        itemBuilder: (BuildContext context, int index) {
          final drinkListItem = drinkList[index];

          if (drinkListItem is SpaceItem) {
            return Container(width: itemWidthWithPadding);
          }

          if (drinkListItem is DrinkListItem) {
            return DrinkFilterItem(
              key: Keys.drinkItem(index),
              width: itemWidthWithPadding - padding * 2,
              drink: drinkListItem.drink,
              onTap: () {
                _updateSelectedPosition();
                controller
                    .animateTo(
                        controller.position.pixels +
                            ((index - 2) - selectedPosition) *
                                itemWidthWithPadding,
                        curve: Curves.easeOut,
                        duration: Duration(milliseconds: 250))
                    .then((_) {
                  widget.onItemTaped(selectedPosition);
                });
              },
            );
          }
        },
      ),
    );
  }

  void _upScroll(double itemWidth) async {
    Future.microtask(() {
      upScrolling = true;

      ListCurrentScreenPosition listPosition = _updateSelectedPosition();

      controller
          .animateTo(
              listPosition.lastItemVisiblePart > 0.5
                  ? controller.position.pixels +
                      itemWidth * (1 - listPosition.lastItemVisiblePart)
                  : controller.position.pixels -
                      itemWidth * listPosition.lastItemVisiblePart,
              curve: Curves.easeOut,
              duration: Duration(milliseconds: 250))
          .then((_) {
        upScrolling = false;
        isListScrolling = false;
        scrolledPixels = controller.position.pixels;
        widget.onPullUpComplete(selectedPosition);
      }).catchError((_) {
        scrolledPixels = controller.position.pixels;
        upScrolling = false;
        isListScrolling = false;
      });
    });
  }

  ListCurrentScreenPosition _updateSelectedPosition() {
    var screenWidth = MediaQuery.of(context).size.width;
    var itemWidthWithPadding = screenWidth / 5;
    double lastPositionVisiblePart =
        controller.position.pixels / itemWidthWithPadding;
    int lastVisiblePosition = lastPositionVisiblePart.toInt();

    double visiblePart = lastPositionVisiblePart - lastVisiblePosition;
    selectedPosition =
        visiblePart > 0.5 ? lastVisiblePosition + 1 : lastVisiblePosition;

    return ListCurrentScreenPosition(
        selectedPosition: selectedPosition, lastItemVisiblePart: visiblePart);
  }
}

class ListItem {}

class SpaceItem implements ListItem {
  SpaceItem();
}

class DrinkListItem implements ListItem {
  final Drink drink;

  DrinkListItem(this.drink);
}

class ListCurrentScreenPosition {
  final int selectedPosition;
  double lastItemVisiblePart;

  ListCurrentScreenPosition({this.selectedPosition, this.lastItemVisiblePart});
}
