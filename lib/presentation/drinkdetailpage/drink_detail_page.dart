import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/firestoredimage/firestored_image.dart';
import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/presentation/cocktaildetailpage/cocktail_detail_page.dart';
import 'package:cocktail_rush/presentation/drinkdetailpage/animated_bar_fab.dart';
import 'package:cocktail_rush/presentation/routes/fade_route.dart';
import 'package:cocktail_rush/presentation/widgets/circle_border_image.dart';
import 'package:cocktail_rush/presentation/widgets/snack_notifier_widget.dart';
import 'package:cocktail_rush/selectors/selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class DrinkDetailPage extends StatefulWidget {
  final Drink _drink;

  DrinkDetailPage(this._drink);

  @override
  DrinkDetailPageState createState() {
    return new DrinkDetailPageState();
  }
}

class DrinkDetailPageState extends State<DrinkDetailPage> {

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel(widget._drink,
          cocktailListByDrinkSelector(store.state, widget._drink), store),
      builder: (context, viewModel) {
        return SnackNotifierWidget(
          item: widget._drink,
          getActionText: () {
            String action;
            if (widget._drink.isSelected()) {
              action = "${widget._drink.name} ${CrLocalization.of(context).actionAddedToBar}";
            } else {
              action = "${widget._drink.name} ${CrLocalization.of(context).actionRemovedFromBar}";
            }
            return action;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: AnimatedBarFab(
              drink: widget._drink,
              onAddToBar: (drink) => viewModel.onAddToBar(drink),
              onRemoveFromBar: (drink) => viewModel.onRemoveFromBar(drink),
            ),
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    expandedHeight: 250.0,
                    floating: false,
                    elevation: 0,
                    iconTheme: IconThemeData(
                      color: Colors.pink,
                    ),
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      collapseMode: CollapseMode.parallax,
                      title: Text(widget._drink.name,
                          style: TextStyle(
                              color: Colors.purple[900], fontSize: 16.0)),
                      background: Container(
                          margin: EdgeInsets.all(64.0),
                          child: FireStoredImage.inBarListItem(
                              150, widget._drink.image)),
                    ),
                  ),
                ];
              },
              body: ScrollConfiguration(
                behavior: NoScrollGlowBehavior(),
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    child: Column(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(widget._drink.story,
                            style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0)),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: viewModel.cocktails
                              .map((cocktail) =>
                                  _buildSingleItem(cocktail, context))
                              .toList(),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleItem(Cocktail cocktail, BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(FadeRoute(
            builder: (_) => CocktailDetailPage(cocktail: cocktail, hero: false),
          ));
        },
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleBorderImage(
                  imageUrl: cocktail.image,
                  diameter: 70.0,
                  borderColor: Colors.purple,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                    child: Text(
                  cocktail.name,
                  maxLines: null,
                  style: TextStyle(
                      color: Colors.purple[900],
                      fontWeight: FontWeight.normal,
                      fontSize: 18.0),
                )),
              ],
            )));
  }
}

class NoScrollGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _ViewModel {
  Drink drink;
  List<Cocktail> cocktails;
  Function(Drink) onAddToBar;
  Function(Drink) onRemoveFromBar;

  _ViewModel(this.drink, this.cocktails, Store<AppState> store) {
    cocktails.sort((c1, c2) => c1.name.compareTo(c2.name));
    onAddToBar =
        (drink) => store.dispatch(UpdateBarInStorageAction(drink, true));
    onRemoveFromBar =
        (drink) => store.dispatch(UpdateBarInStorageAction(drink, false));
  }
}
