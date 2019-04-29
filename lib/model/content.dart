import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/drink.dart';

class Content {
  final List<Cocktail> cocktails;
  final List<Drink> drinks;

  const Content({this.cocktails, this.drinks});

  const Content.empty()
      : cocktails = const [],
        drinks = const [];
}
