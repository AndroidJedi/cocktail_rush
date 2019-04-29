import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/presentation/drinkdetailpage/drink_detail_page.dart';
import 'package:cocktail_rush/presentation/menu/zoom_scaffold.dart';
import 'package:cocktail_rush/presentation/mybarpage/category_selector.dart';
import 'package:cocktail_rush/presentation/mybarpage/drink_item.dart';
import 'package:cocktail_rush/presentation/mybarpage/fade_in_widget.dart';
import 'package:cocktail_rush/presentation/mybarpage/scrollable_drink_filter.dart';
import 'package:cocktail_rush/presentation/routes/fade_route.dart';
import 'package:cocktail_rush/presentation/search/search_bloc.dart';
import 'package:collection/equality.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MyBarPage extends StatefulWidget {
  final List<Drink> drinks;

  MyBarPage({@required this.drinks, Key key}) : super(key: key);

  @override
  MyBarPageState createState() {
    return new MyBarPageState();
  }
}

class MyBarPageState extends State<MyBarPage> with TickerProviderStateMixin {
  final SearchBloc<Drink> searchDrinkBloc = SearchBloc();
  Category selectedCategory = Category.ALC;
  bool switchingAllowed = true;
  SearchControllerBloc searchControllerBloc;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ListModel<Drink> _list;

  @override
  void initState() {
    searchControllerBloc = getSearchControllerBloc(context);
    searchDrinkBloc.setSourceList(widget.drinks);
    searchControllerBloc.querySubject.stream
        .listen(searchDrinkBloc.textChangeListener);
    localBarDrinkList.addAll(
        searchDrinkBloc.getSourceList().where((drink) => drink.inBar).toList());
    _list = ListModel<Drink>(
      listKey: _listKey,
      initialItems: searchDrinkBloc
          .getSourceList()
          .where((drink) => drink.inBar)
          .toList(),
      removedItemBuilder: _buildRemovedItem,
    );
    super.initState();
  }

  @override
  void dispose() {
    searchControllerBloc.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MyBarPage oldWidget) {
    if (!DeepCollectionEquality().equals(widget.drinks, _currentDrinks)) {
      searchControllerBloc = getSearchControllerBloc(context);
      searchDrinkBloc.setSourceList(widget.drinks);
      _currentDrinks.clear();
      _currentDrinks.addAll(widget.drinks);
    }

    super.didUpdateWidget(oldWidget);
  }

  List<Drink> _currentDrinks = List();

  SearchControllerBloc getSearchControllerBloc(BuildContext context) {
    final scaffoldState =
        context.ancestorStateOfType(new TypeMatcher<ZoomScaffoldState>())
            as ZoomScaffoldState;
    return scaffoldState.drinkSearchBloc;
  }

  void _onCategorySelected(Category value) async {
    setState(() {
      selectedCategory = value;
    });
  }

  List<Drink> localBarDrinkList = List();

  _updateLocalBarDrinkList(List<Drink> blockList) {
    if (DeepCollectionEquality.unordered()
        .equals(localBarDrinkList, blockList)) {
      return;
    }

    if (blockList.length > localBarDrinkList.length) {
      //item was added

      localBarDrinkList.forEach((drink) {
        blockList.remove(drink);
      });

      Drink drinkToAdd = blockList[0];
      if (drinkToAdd != null) {
        localBarDrinkList.insert(0, drinkToAdd);

        _list.insert(0, drinkToAdd);
      }
    } else if (blockList.length < localBarDrinkList.length) {
      //item was removed

      List<Drink> tempList = List();

      tempList.addAll(localBarDrinkList);

      blockList.forEach((drink) {
        localBarDrinkList.remove(drink);
      });

      if (localBarDrinkList.length > 1) {
        throw Exception("Only one element can be removed at a time");
      }

      tempList.remove(localBarDrinkList.first);

      _list.removeAt(_list.indexOf(localBarDrinkList.first));

      localBarDrinkList.clear();

      localBarDrinkList.addAll(tempList);

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateLocalBarDrinkList(
        searchDrinkBloc.getSourceList().where((drink) => drink.inBar).toList());

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: StreamBuilder<List<Drink>>(
          stream: searchDrinkBloc.filteredList,
          initialData: searchDrinkBloc.filteredList.value,
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: <Widget>[
                  CategorySelectorWidget(
                      selectedSearchFilter: selectedCategory,
                      onCategorySelected: _onCategorySelected),
                  ScrollableDrinkFilter(
                    drinkList: snapshot.data,
                    selectedCategory: selectedCategory,
                    onFilterSwitchStarted: () {
                      switchingAllowed = false;
                    },
                    onFilterSwitchComplete: () {
                      switchingAllowed = true;
                    },
                  ),
                  StoreConnector<AppState, OnDrinkInBarUpdated>(
                    converter: (store) {
                      return (Drink drink, bool wasAdded) {
                        store.dispatch(
                            UpdateBarInStorageAction(drink, wasAdded));
                      };
                    },
                    builder: (context, vm) {
                      return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: IconButton(
                            iconSize: 50.0,
                            color: Colors.green,
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              if (keyDrinkFilterState.currentState.selectedDrink != null) {
                                vm(keyDrinkFilterState.currentState.selectedDrink, true);
                              }
                            },
                          ));
                    },
                  ),
                  Expanded(
                    child: _buildListView(),
                  )
                ],
              ),
            );
          }),
    );
  }

  Widget _buildRemovedItem(
      Drink item, BuildContext context, Animation<double> animation) {
    return DrinkBarItem(
      animation: animation,
      drink: item,
      onTap: () {},
    );
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return DrinkBarItem(
      animation: animation,
      drink: _list[index],
      onTap: () {
        Navigator.of(context).push(FadeRoute(
          builder: (_) => DrinkDetailPage(_list[index]),
        ));
      },
    );
  }

  AssetImage _assetImage = new AssetImage('assets/image_my_bar.png');

  Widget _buildListView() {
    if (_list.length == 0) {
      return FadeInWidget(
        key: Key("key_empty_state_image"),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: new BoxDecoration(
            image: DecorationImage(
              image: _assetImage,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    return FadeInWidget(
      key: Key("key_my_bar_list"),
      child: Container(
        width: double.infinity,
        child: AnimatedList(
          key: _listKey,
          initialItemCount: _list.length,
          itemBuilder: _buildItem,
        ),
      ),
    );
  }
}

class ListModel<E> {
  ListModel({
    @required this.listKey,
    @required this.removedItemBuilder,
    Iterable<E> initialItems,
  })  : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    try {
      _items.insert(index, item);
      _animatedList.insertItem(index);
    } catch (e) {
      print("TAG insert error $e");
    }
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(index,
          (BuildContext context, Animation<double> animation) {
        return removedItemBuilder(removedItem, context, animation);
      });
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}

typedef OnDrinkInBarUpdated = Function(Drink drink, bool wasAdded);
