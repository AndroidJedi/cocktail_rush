
import 'package:cocktail_rush/actions/actions.dart';

bool searchReducer (bool searching, dynamic action) {
  if(action is SearchingAction){
    return action.isSearching;
  }
  return searching;
}