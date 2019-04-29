import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/model/ingredient.dart';
import 'package:cocktail_rush/presentation/main_page.dart';

bool isLoadingSelector(AppState state) => state.isLoading;

List<Cocktail> cocktailListSelector(AppState state) => state.content.cocktails;

List<Cocktail> cocktailListByDrinkSelector(AppState state, Drink drink) {
  return state.content.cocktails
      .where((cocktail) => _filterIngredientsByDrinks(cocktail.ingredients, drink))
      .toList();
}


bool _filterIngredientsByDrinks(List<Ingredient> ingredients, Drink drink) {
  try{
     ingredients.firstWhere((i) => i.drinkId == drink.id);
     return true;
  }catch(IterableElementError){
    return false;
  }

}

Page activeTabSelector(AppState state) => state.activePage;


Drink drinkForIngredientSelector(AppState state, Ingredient ingredient){
 return  state.content.drinks.firstWhere((drink)=>drink.id == ingredient.drinkId);
}
