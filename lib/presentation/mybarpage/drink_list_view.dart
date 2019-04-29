import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/model/utils.dart';
import 'package:cocktail_rush/presentation/drinkdetailpage/drink_detail_page.dart';
import 'package:cocktail_rush/presentation/mybarpage/animated_drink_name_widget.dart';
import 'package:cocktail_rush/presentation/mybarpage/pull_up_list.dart';
import 'package:cocktail_rush/presentation/routes/fade_route.dart';
import 'package:flutter/material.dart';

class DrinkListView extends StatefulWidget {
  final List<Drink> drinkList;
  final Function(Drink) onItemSelected;

  DrinkListView({this.drinkList, this.onItemSelected, Key key})
      : super(key: key);

  @override
  DrinkListViewState createState() {
    return new DrinkListViewState();
  }
}

class DrinkListViewState extends State<DrinkListView>
    with SingleTickerProviderStateMixin {
  int selectedPosition = 0;
  AnimationController nameAnimationController;

  @override
  void initState() {
    nameAnimationController = AnimationController(
        value: 1.0, duration: const Duration(milliseconds: 200), vsync: this);
    _selectItem();
    super.initState();
  }

  void _selectItem() async {
    if (widget.drinkList.length > 0) {
      widget.onItemSelected(widget.drinkList[selectedPosition]);
    }
  }

  @override
  void dispose() {
    nameAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _selectItem();
    return Column(
      children: <Widget>[
        Container(
            height: 84.0,
            child: PullUpListView(
                drinkList: widget.drinkList,
                onScrollStarted: () {
                  widget.onItemSelected(null);
                  nameAnimationController.reverse(from: 1.0);
                },
                onPullUpComplete: (int selectedPosition) {
                  nameAnimationController.value = 0.0;
                  nameAnimationController.forward(from: 0.0);
                  setState(() {
                    this.selectedPosition = selectedPosition;
                    widget.onItemSelected(widget.drinkList[selectedPosition]);
                  });
                },
                onItemTaped: (int selectedPosition) {
                  setState(() {
                    if (this.selectedPosition == selectedPosition &&
                        widget.drinkList.length > 0) {
                      Navigator.of(context).push(FadeRoute(
                          builder: (_) => DrinkDetailPage(
                              widget.drinkList[selectedPosition])));
                    } else {
                      this.selectedPosition = selectedPosition;
                      widget.onItemSelected(widget.drinkList[selectedPosition]);
                    }
                  });
                })),
        AnimatedDrinkNameWidget(
          drinkName: _getDrinkName(),
          animation: nameAnimationController,
        )
      ],
    );
  }

  String _getDrinkName() {
    if (widget.drinkList.length == 0) {
      return CrLocalization.of(context).noSearchResult;
    } else {
      if (selectedPosition > widget.drinkList.length - 1) {
        return "";
      } else {
        return widget.drinkList[selectedPosition].name;
      }
    }
  }
}
