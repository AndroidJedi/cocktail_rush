import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/model/ingredient.dart';
import 'package:cocktail_rush/presentation/drinkdetailpage/drink_detail_page.dart';
import 'package:cocktail_rush/presentation/routes/fade_route.dart';
import 'package:cocktail_rush/presentation/widgets/circle_border_image.dart';
import 'package:cocktail_rush/selectors/selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class Ingredients extends StatelessWidget {
  final List<Ingredient> ingredients;

  Ingredients(this.ingredients);

  Widget _buildSingleIngredient(Ingredient ingredient, bool divided) {
    if (divided) {
      return Column(children: <Widget>[
        BareIngredient(ingredient),
        Divider(
          height: 8.0,
          color: Colors.pink[300],
        )
      ]);
    } else {
      return  Column(children: <Widget>[
        BareIngredient(ingredient),
        SizedBox(
          height: 80.0,
          width: double.infinity,
        )
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              CrLocalization.of(context).ingredientsTitle,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.purple,
              ),
            ),
          ),
        ),
        Column(
          children: ingredients
              .map((ingredient) => _buildSingleIngredient(
                  ingredient,
                  ingredient.drinkId != ingredients.last.drinkId))
              .toList(),
        ),
      ],
    );
  }
}

class BareIngredient extends StatelessWidget {
  final Ingredient _ingredient;

  BareIngredient(this._ingredient);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _BareIngredientViewModel>(
      converter: (store) =>
          _BareIngredientViewModel.fromStore(store, _ingredient),
      builder: (context, vm) {
        return ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          onTap: () {
            Navigator.of(context).push(
              //  MaterialPageRoute(builder: (_) => DrinkDetailPage(vm.drink)));
                FadeRoute(builder: (_) => DrinkDetailPage(vm.drink)));
          },
          leading: Stack(children: [
            CircleBorderImage(imageUrl: vm.drink.image, diameter: 50.0),
            vm.drink.inBar
                ? Positioned(
                left: 1,
                bottom: 1,
                child: Icon(
                  Icons.local_bar,
                  size: 20,
                  color: Colors.pink,
                ))
                : Container(width: 0, height: 0)
          ]),
          title: Text(
            vm.drink.name,
            style: const TextStyle(fontSize: 17.0, color: Colors.purple),
            maxLines: null,
          ),
          trailing: Text(
            _ingredient.measuredQuantity(context),
            style: const TextStyle(fontSize: 17.0, color: Colors.purple),
            maxLines: null,
          ),
          subtitle: Text(
            _ingredient.drink.usedInNumberOfCocktails(context),
            style: const TextStyle(fontSize: 15.0, color: Colors.purple),
            maxLines: null,
          ),
        );
      },
    );
  }
}

class _BareIngredientViewModel {
  Drink drink;

  _BareIngredientViewModel(this.drink);

  static _BareIngredientViewModel fromStore(
      Store<AppState> store, Ingredient ingredient) {
    return _BareIngredientViewModel(
        drinkForIngredientSelector(store.state, ingredient));
  }
}
