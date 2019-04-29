import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/content.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/presentation/main_page.dart';
import 'package:cocktail_rush/model/cocktails_repository.dart';
import 'package:flutter/painting.dart';

class LoadContentFromStorageAction {
  Locale locale;

  LoadContentFromStorageAction(this.locale);
}

class FetchContentFromRepositoryAction {
  bool localStorageIsEmpty;
  Locale locale;

  FetchContentFromRepositoryAction(this.localStorageIsEmpty, this.locale);
}

class StoreAllContentAction {
  final RepoContent repoContent;

  StoreAllContentAction(this.repoContent);
}

class UpdateStorageAction {
  final RepoContent repoContent;

  UpdateStorageAction(this.repoContent);
}

class ShowContentAction {
  final Content content;

  ShowContentAction(this.content);
}

class SortCocktailsAction {}

class ShowSortedCocktailsAction {
  List<Cocktail> cocktails;

  ShowSortedCocktailsAction(this.cocktails);
}

class ContentNotLoadedAction {}

class UpdateBarErrorAction {}

class SearchingAction {
  bool isSearching;

  SearchingAction(this.isSearching);
}

class SelectPageAction {
  Page page;

  SelectPageAction(this.page);
}

class UpdateBarAction {
  Drink drink;
  bool added;

  UpdateBarAction(this.drink, this.added);
}

class UpdateFavAction {
  Cocktail cocktail;
  bool added;

  UpdateFavAction(this.cocktail, this.added);
}

class UpdateBarInStorageAction {
  Drink drink;
  bool added;

  UpdateBarInStorageAction(this.drink, this.added);
}

class UpdateFavoriteCocktailsInStorageAction {
  Cocktail cocktail;
  bool added;

  UpdateFavoriteCocktailsInStorageAction(this.cocktail, this.added);
}

class LocaleChangeAction {
  Locale locale;

  LocaleChangeAction(this.locale);
}

class UpdateStoreLocaleAction {
  Locale locale;

  UpdateStoreLocaleAction(this.locale);
}

class ShowLoadImagesAction {}
