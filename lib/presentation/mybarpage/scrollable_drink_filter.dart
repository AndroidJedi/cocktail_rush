import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/presentation/mybarpage/category_selector.dart';
import 'package:cocktail_rush/presentation/mybarpage/drink_list_view.dart';
import 'package:flutter/material.dart';

class ScrollableDrinkFilter extends StatefulWidget {
  final List<Drink> drinkList;
  final Category selectedCategory;
  final VoidCallback onFilterSwitchComplete;
  final VoidCallback onFilterSwitchStarted;

  ScrollableDrinkFilter(
      {this.drinkList,
      this.selectedCategory,
      this.onFilterSwitchStarted,
      this.onFilterSwitchComplete,
      }):super(key: keyDrinkFilterState);

  @override
  _ScrollableDrinkFilterState createState() => _ScrollableDrinkFilterState();
}

final GlobalKey<_ScrollableDrinkFilterState> keyDrinkFilterState = GlobalKey<_ScrollableDrinkFilterState>();

class _ScrollableDrinkFilterState extends State<ScrollableDrinkFilter>
    with TickerProviderStateMixin {
  AnimationController switchAnimationController;

  static Tween<double> animateOutTween = Tween(begin: 0, end: -124);
  static Tween<double> animateInTween = Tween(begin: 124, end: 0);

  Drink selectedDrink;

  ///////////
  double currentListOpacity = 1.0;
  double currentListPosition = 0.0;

  double selectedListPosition = 124.0;
  double selectedListOpacity = 0.0;

  ///////////////

  double alcListOpacity = 1.0;
  double alcListPosition = 0.0;

  double noAlcListOpacity = 0.0;
  double noAlcListPosition = 124;

  double otherListOpacity = 0.0;
  double otherListPosition = 124;

  Category currentSearchFilter = Category.ALC;

  @override
  void didUpdateWidget(ScrollableDrinkFilter oldWidget) {
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      if (_animationNotRunning()) {
        widget.onFilterSwitchStarted();
        switchAnimationController.forward(from: 0.0);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    switchAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addListener(() {
            setState(() {
              currentListOpacity = 1 - switchAnimationController.value;
              selectedListOpacity = switchAnimationController.value;

              currentListPosition =
                  animateOutTween.evaluate(switchAnimationController);
              selectedListPosition =
                  animateInTween.evaluate(switchAnimationController);

              animateFilterChange(currentSearchFilter, widget.selectedCategory);
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              currentSearchFilter = widget.selectedCategory;
              widget.onFilterSwitchComplete();
            }
          });
    super.initState();
  }

  void animateFilterChange(Category current, Category selected) {
    switch (current) {
      case Category.ALC:
        alcListOpacity = currentListOpacity;
        alcListPosition = currentListPosition;
        break;
      case Category.NO_ALC:
        noAlcListOpacity = currentListOpacity;
        noAlcListPosition = currentListPosition;
        break;
      case Category.OTHER:
        otherListOpacity = currentListOpacity;
        otherListPosition = currentListPosition;
        break;
    }
    switch (selected) {
      case Category.ALC:
        alcListOpacity = selectedListOpacity;
        alcListPosition = selectedListPosition;
        break;
      case Category.NO_ALC:
        noAlcListOpacity = selectedListOpacity;
        noAlcListPosition = selectedListPosition;
        break;
      case Category.OTHER:
        otherListOpacity = selectedListOpacity;
        otherListPosition = selectedListPosition;
        break;
    }
  }

  bool _animationNotRunning() {
    return switchAnimationController.status != AnimationStatus.forward &&
        switchAnimationController.status != AnimationStatus.reverse;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        child: Stack(
         children: <Widget>[
            Opacity(
              opacity: alcListOpacity,
              child: Transform.translate(
                offset: Offset(0.0, alcListPosition),
                child: DrinkListView(
                    drinkList: widget.drinkList
                        .where((drink) => drink.category == Category.ALC.value)
                        .toList(),
                    onItemSelected: (drink) {
                      if(currentSearchFilter ==  Category.ALC){
                        selectedDrink = drink;
                      }
                    }),
              ),
            ),
            Opacity(
              opacity: noAlcListOpacity,
              child: Transform.translate(
                  offset: Offset(0.0, noAlcListPosition),
                  child: DrinkListView(
                      drinkList: widget.drinkList
                          .where((drink) =>
                              drink.category == Category.NO_ALC.value)
                          .toList(),
                      onItemSelected: (drink) {
                        if(currentSearchFilter ==  Category.NO_ALC){
                          selectedDrink = drink;
                        }
                      })),
            ),
            Opacity(
              opacity: otherListOpacity,
              child: Transform.translate(
                  offset: Offset(0.0, otherListPosition),
                  child: DrinkListView(
                      drinkList: widget.drinkList
                          .where(
                              (drink) => drink.category == Category.OTHER.value)
                          .toList(),
                      onItemSelected: (drink) {
                        if(currentSearchFilter ==  Category.OTHER){
                          selectedDrink = drink;
                        }
                      })),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    switchAnimationController.dispose();
    super.dispose();
  }
}
