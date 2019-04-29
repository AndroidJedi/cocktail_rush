
import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/model/drink.dart';

List<Drink> drinkListReducer (List<Drink> stateList, dynamic action){

  if(action is UpdateStorageAction){
    return action.repoContent.drinks;
  }

  return stateList;
}