import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

class CrLocalization {
  CrLocalization(this.locale);

  final Locale locale;

  static CrLocalization of(BuildContext context) {
    return Localizations.of<CrLocalization>(context, CrLocalization);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'menu_item_cocktails': 'Cocktails',
      'menu_item_my_bar': 'My Bar',
      'menu_item_shaker': 'Shaker',
      'menu_item_favourite': 'Favourite',
      'menu_item_promo': 'Help us grow',
      'ingredients_title': 'Ingredients',
      'dosage_ml': ' ml',
      'dosage_gr': ' gr',
      'dosage_pc': ' pc',
      'search_hint': 'Search...',
      'cocktails_count_single': 'in %s cocktail',
      'cocktails_count_multiple': 'in %s cocktails',
      'no_search_result': 'No results',
      'added_to_fav': ' was added to Favourites',
      'removed_from_fav': ' was removed from Favourites',
      'added_to_bar': ' was added to Bar',
      'removed_from_bar': ' was removed from Bar',
      'filter_item_alc': 'Alc',
      'filter_item_mixers': 'Mixers',
      'filter_item_other': 'Other',
      'offline': 'You are offline',
      'cocktails_page_snackbar_text': 'Sorted by My Bar ingredients',
      'shake_page_hint': 'Shake your device',
      'cocktails_page_images_loading_snack_message': 'Please wait while the images are loading',
    },
    'ru': {
      'menu_item_cocktails': 'Коктейли',
      'menu_item_my_bar': 'Мой Бар',
      'menu_item_shaker': 'Шейкер',
      'menu_item_favourite': 'Любимые',
      'menu_item_promo': 'Промо',
      'ingredients_title': 'Ингредиенты',
      'dosage_ml': ' мл',
      'dosage_gr': ' гр',
      'dosage_pc': ' шт',
      'search_hint': 'Поиск...',
      'cocktails_count_single': 'в %s коктейлe',
      'cocktails_count_multiple': 'в %s коктейлях',
      'no_search_result': 'Нет результатов',
      'added_to_fav': ' был добавлен в Любимые',
      'removed_from_fav': ' был удален из Любимых',
      'added_to_bar': ' был добавлен в Мой Бар',
      'removed_from_bar': ' был удален из Моего Бара',
      'filter_item_alc': 'Алк.',
      'filter_item_mixers': 'Наполнители',
      'filter_item_other': 'Другие',
      'offline': 'Нет подключения к сети',
      'cocktails_page_snackbar_text': 'Отсортированно по напиткам в Баре',
      'shake_page_hint': 'Потрясите телефон',
      'cocktails_page_images_loading_snack_message': 'Пожалуйста, дождитесь загрузки картинок',
    }
  };

  String get menuItemCocktails {
    return _localizedValues[locale.languageCode]['menu_item_cocktails'];
  }

  String get menuItemMyBar {
    return _localizedValues[locale.languageCode]['menu_item_my_bar'];
  }

  String get menuFavBar {
    return _localizedValues[locale.languageCode]['menu_item_favourite'];
  }

  String get menuShaker {
    return _localizedValues[locale.languageCode]['menu_item_shaker'];
  }

  String get menuPromo {
    return _localizedValues[locale.languageCode]['menu_item_promo'];
  }

  String get ingredientsTitle {
    return _localizedValues[locale.languageCode]['ingredients_title'];
  }

  String get dosageMl {
    return _localizedValues[locale.languageCode]['dosage_ml'];
  }

  String get dosageGr {
    return _localizedValues[locale.languageCode]['dosage_gr'];
  }

  String get dosagePc {
    return _localizedValues[locale.languageCode]['dosage_pc'];
  }

  String get cocktailsCountSingle {
    return _localizedValues[locale.languageCode]['cocktails_count_single'];
  }

  String get cocktailsCountMultiple {
    return _localizedValues[locale.languageCode]['cocktails_count_multiple'];
  }

  String get searchHint {
    return _localizedValues[locale.languageCode]['search_hint'];
  }

  String get noSearchResult {
    return _localizedValues[locale.languageCode]['no_search_result'];
  }

  String get actionAddedToFav {
    return _localizedValues[locale.languageCode]['added_to_fav'];
  }

  String get actionRemovedFromFav {
    return _localizedValues[locale.languageCode]['removed_from_fav'];
  }

  String get actionAddedToBar {
    return _localizedValues[locale.languageCode]['added_to_bar'];
  }

  String get actionRemovedFromBar {
    return _localizedValues[locale.languageCode]['removed_from_bar'];
  }

  String get filterItemAlc {
    return _localizedValues[locale.languageCode]['filter_item_alc'];
  }

  String get filterItemMixers {
    return _localizedValues[locale.languageCode]['filter_item_mixers'];
  }

  String get filterItemOther {
    return _localizedValues[locale.languageCode]['filter_item_other'];
  }

  String get offline {
    return _localizedValues[locale.languageCode]['offline'];
  }

  String get cocktailsPageSnackBarText {
    return _localizedValues[locale.languageCode]['cocktails_page_snackbar_text'];
  }

  String get shakePageHint {
    return _localizedValues[locale.languageCode]['shake_page_hint'];
  }

  String get cocktailsPageImagesLoadingSnackMessage {
    return _localizedValues[locale.languageCode]['cocktails_page_images_loading_snack_message'];
  }

}


class CrLocalizationsDelegate extends LocalizationsDelegate<CrLocalization> {
  Store<AppState> store;

  CrLocalizationsDelegate(this.store);

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<CrLocalization> load(Locale locale) {
    return SynchronousFuture<CrLocalization>(CrLocalization(locale))
        .then((crLocale) {
      store.dispatch(LocaleChangeAction(crLocale.locale));
      return crLocale;
    });
  }

  @override
  bool shouldReload(CrLocalizationsDelegate old) => false;
}
