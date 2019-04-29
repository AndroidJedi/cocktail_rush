import 'package:cocktail_rush/model/generic.dart';
import 'package:cocktail_rush/presentation/cocktailpage/cocktails_page.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cocktail_rush/model/utils.dart';

class SearchBloc<T extends Searchable> {
  final List<T> _sourceList = List();

  final BehaviorSubject<List<T>> filteredList =
      BehaviorSubject(seedValue: List<T>());

  Function (String) textChangeListener;



  SearchBloc() {
    textChangeListener = (query) {
      List<T> searchResultList = _sourceList
          .where((item) => item
              .getItemName()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      filteredList.add(searchResultList);
    };

  }

  void setSourceList(List<T> sourceList) {
    if (compareCocktailListOrdered(_sourceList, sourceList)) {
      return;
    }
    filteredList.add(sourceList);
    _sourceList.clear();
    _sourceList.addAll(sourceList);
  }

  List<T> getSourceList(){
    return _sourceList;
  }

  void dispose() {
    filteredList.close();
  }
}
///TODO: remove SearchState
class SearchState {
  final bool isEnabled;
  final bool showProgress;

  SearchState(
      {
      @required this.isEnabled,
      @required this.showProgress});


  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final SearchState otherSearchState = other;
    return isEnabled == otherSearchState.isEnabled;
  }


  @override
  String toString() => "{SearchState: isEnabled: $isEnabled, showProgree: $showProgress}";

}
