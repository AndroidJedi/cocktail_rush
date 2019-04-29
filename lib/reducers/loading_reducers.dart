import 'package:cocktail_rush/actions/actions.dart';
import 'package:redux/redux.dart';

final loadingReducer = combineReducers<bool>([
  TypedReducer<bool, ShowContentAction>(_setLoaded),
  TypedReducer<bool, ContentNotLoadedAction>(_setLoaded)
]);

bool _setLoaded(bool state, action){
  return false;
}