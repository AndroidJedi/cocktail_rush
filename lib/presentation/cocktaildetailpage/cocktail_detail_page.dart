import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/firestoredimage/cache/firebase_image_provider.dart';
import 'package:cocktail_rush/firestoredimage/cache/firebase_image_url.dart';
import 'package:cocktail_rush/firestoredimage/firestored_image.dart';
import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/presentation/cocktaildetailpage/animated_cocktail_fab.dart';
import 'package:cocktail_rush/presentation/cocktaildetailpage/ingredients.dart';
import 'package:cocktail_rush/presentation/cocktaildetailpage/preparation_steps.dart';
import 'package:cocktail_rush/presentation/widgets/alc_indicator.dart';
import 'package:cocktail_rush/presentation/widgets/snack_notifier_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class CocktailDetailPage extends StatefulWidget {
  final Cocktail cocktail;
  final bool hero;

  CocktailDetailPage({Key key,@required this.hero, @required this.cocktail})
      : super(key: key);

  @override
  CocktailDetailPageState createState() {
    return new CocktailDetailPageState();
  }
}

class CocktailDetailPageState extends State<CocktailDetailPage> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel(widget.cocktail, store),
      builder: (context, viewModel) {
        return SnackNotifierWidget(
          item: widget.cocktail,
          getActionText: () {
            String action;
            if (widget.cocktail.isSelected()) {
              action = "${widget.cocktail.name} ${CrLocalization.of(context).actionAddedToFav}";
            } else {
              action = "${widget.cocktail.name} ${CrLocalization.of(context).actionRemovedFromFav}";
            }
            return action;
          },
          child: Scaffold(
              floatingActionButton: AnimatedCocktailFab(
                  cocktail: widget.cocktail,
                  onAddToFav: (c) => viewModel.onAddToFav(c),
                  onRemoveFromFav: (c) => viewModel.onRemoveFromFav(c)),
              body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        AppBar(
                          elevation: 0,
                          iconTheme: IconThemeData(
                            color: Colors.purple, //change your color here
                          ),
                          backgroundColor: Theme.of(context).canvasColor,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 16.0, right: 16.0),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  widget.hero
                                      ? Hero(
                                          tag: '${widget.cocktail.id}__heroTag',
                                          child: _buildImage())
                                      : _buildImage(),
                                  Container(
                                      margin: EdgeInsets.only(bottom: 10.0),
                                      child: Row(children: <Widget>[
                                        Expanded(
                                          flex: 9,
                                          child: Text(
                                            widget.cocktail.name,
                                            style: TextStyle(
                                                color: Colors.purple,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child:
                                                AlcIndicator(widget.cocktail.alc))
                                      ])),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 8.0),
                                    child:
                                        PreparationSteps(widget.cocktail.story),
                                  ),
                                  Ingredients(widget.cocktail.ingredients)
                                ])),
                      ],
                    ),
                  ))),
        );
      },
    );
  }

  Widget _buildImage() {
    return FireStoredImage(
        width: double.infinity,
        height: 200,
        placeholder: new Icon(Icons.image, size: 200, color: Colors.pink[50]),
        errorWidget: new Icon(Icons.error, size: 200, color: Colors.pink[50]),
        imageProvider: FireBaseImageProvider(FireBaseUrl(
            nodes: List<String>()..add("cocktails")..add("big"),
            image: widget.cocktail.image)));
  }
}

class _ViewModel {
  Cocktail cocktail;
  Function(Cocktail) onAddToFav;
  Function(Cocktail) onRemoveFromFav;

  _ViewModel(this.cocktail, Store<AppState> store) {
    onAddToFav = (drink) {
      cocktail.isFav = true;
      store.dispatch(UpdateFavoriteCocktailsInStorageAction(cocktail, true));
    };

    onRemoveFromFav = (drink) {
      cocktail.isFav = false;
      store.dispatch(UpdateFavoriteCocktailsInStorageAction(cocktail, false));
    };
  }
}
