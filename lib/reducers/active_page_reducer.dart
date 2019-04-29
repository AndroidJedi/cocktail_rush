import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/presentation/main_page.dart';

Page activePageReducer(Page page, dynamic action){

  if(action is SelectPageAction){
    return action.page;
  }

  return page;

}