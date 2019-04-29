import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/reducers/active_page_reducer.dart';
import 'package:cocktail_rush/reducers/loading_reducers.dart';
import 'package:cocktail_rush/reducers/content_reducer.dart';
import 'package:cocktail_rush/reducers/locale_reducer.dart';
import 'package:cocktail_rush/reducers/show_images_loading_reducer.dart';
import 'package:cocktail_rush/reducers/sorted_cocktails_reducer.dart';

AppState appReducer(AppState state, action) {
  return AppState(
    showLoadingImages: showImagesLoad(state.showLoadingImages, action),
    locale: localeReducer(state.locale, action),
    isLoading: loadingReducer(state.isLoading, action),
    content: contentReducer(state.content, action),
    activePage: activePageReducer(state.activePage, action),
    sortedCocktails: sortedCocktailsReducer(state.sortedCocktails, action),
  );
}
