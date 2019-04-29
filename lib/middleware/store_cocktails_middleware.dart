import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/repository/firebase_cocktails_repository.dart';
import 'package:cocktail_rush/model/cocktails_repository.dart';
import 'package:cocktail_rush/storage/storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:redux/redux.dart';
import 'package:cocktail_rush/model/utils.dart';

List<Middleware<AppState>> createStoreCocktailsMiddleware() {
  CocktailRushRepository repository =
      FirebaseCocktailRushRepository(FirebaseDatabase.instance);
  CocktailRushStorage storage = CocktailsStorageImpl();

  final fetchContentFromStorageMiddleware = _fetchContentFromStorage(storage);
  final storeCocktailsMiddleware = _insertOrUpdateRepoContent(storage);
  final fetchContentFromRepositoryMiddleWare =
      _fetchContentFromCloud(repository);
  final storeAllContent = _storeAllContent(storage);
  final updateDrinkInBarStorage = _updateDrinkInBarStorage(storage);
  final updateFavoriteCocktailsInStorageAction =
      _updateFavoriteCocktailsInStorageAction(storage);
  final reloadContentForLocale = _reloadContentForLocale(storage);

  return [
    TypedMiddleware<AppState, LoadContentFromStorageAction>(
        fetchContentFromStorageMiddleware),
    TypedMiddleware<AppState, FetchContentFromRepositoryAction>(
        fetchContentFromRepositoryMiddleWare),
    TypedMiddleware<AppState, UpdateStorageAction>(storeCocktailsMiddleware),
    TypedMiddleware<AppState, StoreAllContentAction>(storeAllContent),
    TypedMiddleware<AppState, UpdateBarInStorageAction>(
        updateDrinkInBarStorage),
    TypedMiddleware<AppState, UpdateFavoriteCocktailsInStorageAction>(
        updateFavoriteCocktailsInStorageAction),
    TypedMiddleware<AppState, LocaleChangeAction>(reloadContentForLocale),
    TypedMiddleware<AppState, SortCocktailsAction>(_sortByBarItems()),
  ];
}

Middleware<AppState> _reloadContentForLocale(CocktailRushStorage storage) {
  return (Store<AppState> store, action, NextDispatcher next) {
    final localeChangeAction = action as LocaleChangeAction;

    if(store.state.locale == null) {
      store.dispatch(UpdateStoreLocaleAction(localeChangeAction.locale));
      store.dispatch(LoadContentFromStorageAction(localeChangeAction.locale));
      return;
    }
    if (store.state.locale != localeChangeAction.locale) {
      store.dispatch(LoadContentFromStorageAction(localeChangeAction.locale));
    }
  };
}

Middleware<AppState> _storeAllContent(CocktailRushStorage storage) {
  return (Store<AppState> store, action, NextDispatcher next) {
    final storeAllContentAction = action as StoreAllContentAction;
    storage.storeAllContent(storeAllContentAction.repoContent).then((content) {
      store.dispatch(ShowContentAction(content));
      print("${action.toString()} handled _storeAllContent in Middleware");
    }).catchError((e) {
      print("${action.toString()} failed in Middleware: $e");
      next(ContentNotLoadedAction());
    });
  };
}

Middleware<AppState> _updateDrinkInBarStorage(CocktailRushStorage storage) {
  return (Store<AppState> store, action, NextDispatcher next) {
    final updateBarInStorageAction = action as UpdateBarInStorageAction;
    store.dispatch(UpdateBarAction(
        updateBarInStorageAction.drink, updateBarInStorageAction.added));
    storage
        .updateDrinkInBarContent(updateBarInStorageAction.drink)
        .then((result) {
      print(
          "Storage updated drink: ${updateBarInStorageAction.drink} added: ${updateBarInStorageAction.added}");
    }).catchError((e) {
      print(
          "Storage updated failed for drink: ${updateBarInStorageAction.drink} added: ${updateBarInStorageAction.added}");
      print(e);
      next(UpdateBarErrorAction());
    });
  };
}

Middleware<AppState> _updateFavoriteCocktailsInStorageAction(
    CocktailRushStorage storage) {
  return (Store<AppState> store, action, NextDispatcher next) {
    final favAction = action as UpdateFavoriteCocktailsInStorageAction;
    store.dispatch(UpdateFavAction(favAction.cocktail, favAction.added));
    storage.updateCocktail(favAction.cocktail).then((result) {
      print(
          "Storage updated cocktail: ${favAction.cocktail.name} added to Favourites: ${favAction.cocktail.isFav} result: $result");
    }).catchError((e) {
      print(
          "Storage updated failed for cocktail: ${favAction.cocktail} added to Favourites: ${favAction.added}");
      print(e);
      next(UpdateBarErrorAction());
    });
  };
}

Middleware<AppState> _sortByBarItems() {
  return (Store<AppState> store, action, NextDispatcher next) {
    List<Cocktail> sortedCocktails = List.of(store.state.content.cocktails);

    sortedCocktails.forEach((c) {
      c.drinksInBar = 0;
      c.ingredients.forEach((i) {
        if (i.drink.inBar) {
          c.drinksInBar++;
        }
      });
    });
    sortedCocktails.sort((cocktail1, cocktail2) =>
        cocktail2.drinksInBar.compareTo(cocktail1.drinksInBar));
    sortedCocktails.forEach((c) {
      print("${c.name} drinks in bar ${c.drinksInBar}");
    });
    store.dispatch(ShowSortedCocktailsAction(sortedCocktails));
  };
}

Middleware<AppState> _fetchContentFromStorage(CocktailRushStorage storage) {
  return (Store<AppState> store, action, NextDispatcher next) {
    storage.fetchAllContent().then((content) {
      final loadCocktailsAction = action as LoadContentFromStorageAction;
      if (content.cocktails.isEmpty && content.drinks.isEmpty) {
        next(ShowLoadImagesAction());
        next(FetchContentFromRepositoryAction(
            content.cocktails.isEmpty, loadCocktailsAction.locale));
      }

      store.dispatch(ShowContentAction(content));
      print(
          "${action.toString()} handled in _fetchContentFromStorage Middleware");
    }).catchError((e) {
      print("${action.toString()} failed in Middleware $e");
      next(ContentNotLoadedAction());
    });
  };
}

Middleware<AppState> _fetchContentFromCloud(CocktailRushRepository repository) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    final fetchContentFromRepository =
        action as FetchContentFromRepositoryAction;

    repository
        .allContent(fetchContentFromRepository.locale)
        .then((repoContent) {
      print(
          "${action.toString()} handled in _fetchContentFromCloud Middleware");
      if (fetchContentFromRepository.localStorageIsEmpty) {
        store.dispatch(StoreAllContentAction(repoContent));
      } else {
        next(UpdateStorageAction(repoContent));
      }
    }).catchError((e) {
      print("${action.toString()} failed in Middleware $e");
      next(ContentNotLoadedAction());
    });
  };
}

Middleware<AppState> _insertOrUpdateRepoContent(CocktailRushStorage storage) {
  return (Store<AppState> store, action, NextDispatcher next) {
    final updateStorageAction = action as UpdateStorageAction;
    try {
      if (store.state.content.cocktails.isNotEmpty &&
          deepEquals(updateStorageAction.repoContent.cocktails,
              store.state.content.cocktails) &&
          store.state.content.drinks.isNotEmpty &&
          deepEquals(updateStorageAction.repoContent.drinks,
              store.state.content.drinks)) {
        print("return from _fetchCocktailsByName Middleware: no new state");
        return;
      }
      storage
          .insertOrUpdateContent(updateStorageAction.repoContent)
          .then((resultContent) {
        final showContentAction = ShowContentAction(resultContent);
        print(
            "${showContentAction.toString()} dispatched from  in _insertOrUpdateRepoContent Middleware");

        ///TODO: is store.dispatch correct?? maybe should be next action
        store.dispatch(showContentAction);
      }).catchError((e) {
        print(e);
        final contentNotLoadedAction = ContentNotLoadedAction();
        print(
            "${contentNotLoadedAction.toString()} sent from  in _insertOrUpdateRepoContent Middleware");
        next(contentNotLoadedAction);
      });
    } catch (e) {
      print(
          "${action.toString()} failed in _insertOrUpdateRepoContent Middleware $e");
    }
  };
}
