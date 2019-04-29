
import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/model/cocktail.dart';

List<Cocktail> sortedCocktailsReducer (List<Cocktail> cocktails, dynamic action){

  if(action is ShowSortedCocktailsAction){
    return action.cocktails;
  }

  return cocktails;

}