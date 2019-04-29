import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/generic.dart';
import 'package:cocktail_rush/model/utils.dart';
import 'package:cocktail_rush/presentation/cocktailpage/cocktail_list.dart';
import 'package:cocktail_rush/presentation/menu/zoom_scaffold.dart';
import 'package:cocktail_rush/presentation/search/search_bloc.dart';
import 'package:cocktail_rush/presentation/widgets/snack_notifier_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CocktailsPage extends StatefulWidget {
  final List<ComparableSortedCocktail> cocktails;

  CocktailsPage({@required this.cocktails, Key key}) : super(key: key);

  @override
  CocktailsPageState createState() {
    return new CocktailsPageState();
  }
}

class CocktailsPageState extends State<CocktailsPage> {
  final SearchBloc<ComparableSortedCocktail> searchCocktailBloc = SearchBloc();
  SearchControllerBloc searchControllerBloc;

  bool _applyMyBarFilter = false;

  VoidCallback _myBarFilterLister;

  @override
  void initState() {
    searchControllerBloc = getSearchControllerBloc(context);
    searchCocktailBloc.setSourceList(widget.cocktails);
    searchControllerBloc.querySubject.stream
        .listen(searchCocktailBloc.textChangeListener);
    _myBarFilterLister = () {
      _showNotifier();
    };
    (zoomScaffoldKey.currentState as ZoomScaffoldState)
        .myBarFilerNotifier
        .addListener(_myBarFilterLister);
    super.initState();
  }

  void _showNotifier() async {
    setState(() {
      _applyMyBarFilter = true;
    });
  }

  @override
  void didUpdateWidget(CocktailsPage oldWidget) {
    if (!compareCocktailListOrdered(widget.cocktails, _currentCocktails)) {
      searchControllerBloc = getSearchControllerBloc(context);
      searchCocktailBloc.setSourceList(widget.cocktails);
      _currentCocktails.clear();
      _currentCocktails.addAll(widget.cocktails);
    }
    super.didUpdateWidget(oldWidget);
  }

  List<ComparableSortedCocktail> _currentCocktails = List();

  @override
  Widget build(BuildContext context) {
    return SnackNotifierWidget(
      item: SelectableImpl(_applyMyBarFilter),
      child: CocktailList(
        bloc: searchCocktailBloc,
        upScroll: _applyMyBarFilter,
      ),
      getActionText: () => CrLocalization.of(context).cocktailsPageSnackBarText,
      onAnimationCompleted: () {
        setState(() {
          _applyMyBarFilter = false;
        });
      },
    );
  }

  SearchControllerBloc getSearchControllerBloc(BuildContext context) {
    final scaffoldState =
        context.ancestorStateOfType(new TypeMatcher<ZoomScaffoldState>())
            as ZoomScaffoldState;
    return scaffoldState.cocktailSearchBloc;
  }

  @override
  void dispose() {
    searchCocktailBloc.dispose();
    (zoomScaffoldKey.currentState as ZoomScaffoldState)
        .myBarFilerNotifier
        .removeListener(_myBarFilterLister);
    super.dispose();
  }
}

class ComparableSortedCocktail extends Cocktail {
  ComparableSortedCocktail.from(Cocktail cocktail)
      : super(
            cocktail.id,
            cocktail.name,
            cocktail.alc,
            cocktail.image,
            cocktail.story,
            cocktail.ingredients,
            cocktail.drinksInBar,
            cocktail.isFav);

  @override
  bool operator ==(other) {
    return id == other.id &&
        name == other.name &&
        alc == other.alc &&
        image == other.image &&
        drinksInBar == other.drinksInBar &&
        deepEquals(ingredients, other.ingredients);
  }
}

bool compareCocktailListOrdered<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) {
    return false;
  }

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }
  return true;
}
