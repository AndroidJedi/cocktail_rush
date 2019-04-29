import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/model/content.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:redux/redux.dart';

final contentReducer = combineReducers<Content>([
  TypedReducer<Content, ShowContentAction>(_setLoadedCocktails),
  TypedReducer<Content, ContentNotLoadedAction>(_setNoLoadedContent),
  TypedReducer<Content, UpdateBarAction>(_updateBar),
  TypedReducer<Content, UpdateFavAction>(_updateFav),
]);

Content _setLoadedCocktails(Content content, ShowContentAction action) {
  return action.content;
}

Content _setNoLoadedContent(Content content, ContentNotLoadedAction action) {
  return Content.empty();
}

Content _updateBar(Content content, UpdateBarAction action) {
  content.cocktails.forEach((c) {
    c.ingredients.forEach((i) {
      if (i.drink == action.drink) {
        i.drink.inBar = action.added;
        if (action.added) {
          c.drinksInBar++;
        } else {
          c.drinksInBar--;
        }
      }
    });
  });
  content.cocktails.sort((cocktail1, cocktail2) =>
      cocktail2.drinksInBar.compareTo(cocktail1.drinksInBar));
  List<Drink> drinks = content.drinks;
  Drink addedRoBarDrink = drinks.firstWhere((drink) => drink == action.drink);
  addedRoBarDrink.inBar = action.added;
  return content;
}

Content _updateFav(Content content, UpdateFavAction action) {
  content.cocktails.forEach((c) {
    if (c.name == action.cocktail.name) {
      c.isFav = action.cocktail.isFav;
      return content;
    }
  });
  return content;
}
