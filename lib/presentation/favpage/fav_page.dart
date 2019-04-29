import 'package:cocktail_rush/firestoredimage/cache/firebase_image_provider.dart';
import 'package:cocktail_rush/firestoredimage/cache/firebase_image_url.dart';
import 'package:cocktail_rush/firestoredimage/firestored_image.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/ingredient.dart';
import 'package:cocktail_rush/presentation/cocktaildetailpage/cocktail_detail_page.dart';
import 'package:cocktail_rush/presentation/routes/fade_route.dart';
import 'package:cocktail_rush/presentation/widgets/alc_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class FavPage extends StatefulWidget {
  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  AssetImage _assetImage = new AssetImage('assets/image_favs.png');
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        converter: (store) => _ViewModel.fromStore(store.state),
        builder: (context, vm) {
          if (vm._cocktails == null || vm._cocktails.length == 0) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: new BoxDecoration(
                image: DecorationImage(
                  image: _assetImage,
                  fit: BoxFit.fitWidth,
                ),
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: vm._cocktails == null ? 0 : vm._cocktails.length,
              itemBuilder: (BuildContext context, int index) {
                final cocktail = vm._cocktails[index];
                return CocktailFavItem(
                  //  key: Keys.cocktailItem(cocktail.id),
                  cocktail: cocktail,
                  onTap: () => _onTodoTap(context, cocktail),
                );
              },
            );
          }
        });
  }

  _onTodoTap(BuildContext context, Cocktail cocktail) {
    Navigator.of(context).push(FadeRoute(
      builder: (_) => CocktailDetailPage(
            cocktail: cocktail,
            hero: false,
          ),
    ));
  }
}

class _ViewModel {
  List<Cocktail> _cocktails;

  _ViewModel.fromStore(AppState state) {
    _cocktails = state.content.cocktails.where((c) => c.isFav).toList();
  }
}

class CocktailFavItem extends StatelessWidget {
  final Cocktail cocktail;
  final GestureTapCallback onTap;

  const CocktailFavItem(
      {Key key, @required this.cocktail, @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0.0,
        child: ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          onTap: onTap,
          leading: FireStoredImage(
              width: FireStoredImage.imageSize,
              height: FireStoredImage.imageSize,
              placeholder: new Icon(Icons.image,
                  size: FireStoredImage.imageSize, color: Colors.pink[50]),
              errorWidget: new Icon(Icons.error,
                  size: FireStoredImage.imageSize, color: Colors.pink[50]),
              imageProvider: FireBaseImageProvider(FireBaseUrl(
                  nodes: List<String>()..add("cocktails")..add("big"),
                  image: cocktail.image))),
          title: Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Row(children: <Widget>[
                Expanded(
                  flex: 9,
                  child: Text(
                    cocktail.name,
                    style: TextStyle(
                        color: Colors.purple[900],
                        fontWeight: FontWeight.normal,
                        fontSize: 20.0),
                  ),
                ),
                Expanded(flex: 2, child: AlcIndicator(cocktail.alc))
              ])),
          subtitle: _buildDrinkNameList(context, cocktail.ingredients),
        ));
  }

  Widget _buildDrinkNameList(
      BuildContext context, List<Ingredient> ingredients) {
    List<TextSpan> spans = List();

    for (int i = 0; i < ingredients.length; i++) {
      spans.add(TextSpan(
        text: i < ingredients.length - 1
            ? ingredients[i].drink.name + ", "
            : ingredients[i].drink.name,
        style: ingredients[i].drink.inBar
            ? TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 15.0)
            : TextStyle(color: Colors.purple[400], fontSize: 15.0),
      ));
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}
