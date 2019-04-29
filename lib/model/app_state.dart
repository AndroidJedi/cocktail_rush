import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/content.dart';
import 'package:cocktail_rush/presentation/main_page.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:cocktail_rush/model/utils.dart';

@immutable
class AppState {
  final bool isLoading;
  final bool showLoadingImages;
  final Content content;
  final List<Cocktail> sortedCocktails;
  final Page activePage;
  final Locale locale;

  AppState({
    this.isLoading = false,
    this.showLoadingImages = false,
    this.locale,
    this.content = const Content.empty(),
    this.sortedCocktails = const [],
    this.activePage = Page.CocktailList,
  });

  AppState copyWith({Locale locale}) {
    return AppState(locale: locale ?? this.locale);
  }

  factory AppState.loading() => AppState(isLoading: true);

  @override
  int get hashCode =>
      isLoading.hashCode ^
      activePage.hashCode ^
      locale.hashCode ^
      deepHash(sortedCocktails.hashCode) ^
      deepHash(content.drinks.hashCode) ^
      deepHash(content.cocktails.hashCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          locale == other.locale &&
          activePage == other.activePage &&
          deepEquals(sortedCocktails, other.sortedCocktails) &&
          deepEquals(content.cocktails, other.content.cocktails) &&
          deepEquals(content.drinks, other.content.drinks);

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading, '
        'activePage: $activePage, '
        'drinkList: ${content.drinks}, '
        'locale: $locale, '
        'sortedCocktails: $sortedCocktails, '
        'cocktailList: ${content.cocktails}';
  }
}
