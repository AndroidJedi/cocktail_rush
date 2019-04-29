import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/generic.dart';
import 'package:cocktail_rush/presentation/main_page.dart';
import 'package:cocktail_rush/presentation/search/search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';

typedef OnPageChanged = Function(Page page);

final zoomScaffoldKey = new GlobalKey(debugLabel: 'ZoomScaffold');

class ZoomScaffold<T extends Searchable> extends StatefulWidget {
  final Widget menuScreen;
  final Screen contentScreen;

  ZoomScaffold({
    this.menuScreen,
    this.contentScreen,
  }) : super(key: zoomScaffoldKey);

  @override
  ZoomScaffoldState createState() => new ZoomScaffoldState();
}

class SearchControllerBloc {
  final BehaviorSubject<SearchState> searchState = BehaviorSubject(
      seedValue: SearchState(isEnabled: false, showProgress: false));
  final BehaviorSubject<String> querySubject = BehaviorSubject(seedValue: "");
  TextEditingController searchQuery = TextEditingController();

  SearchControllerBloc() {
    searchQuery.addListener(() {
      querySubject.add(searchQuery.value.text);
    });
  }

  void dispose() {
    searchState.close();
    searchQuery.dispose();
  }
}

class _ViewModel {
  Page currentPage;
  Function onSortByBarItems;

  _ViewModel.fromStore(Store<AppState> store) {
    currentPage = store.state.activePage;
    onSortByBarItems = () => store.dispatch(SortCocktailsAction());
  }
}

class ZoomScaffoldState extends State<ZoomScaffold>
    with TickerProviderStateMixin {
  MenuController menuController;
  SearchControllerBloc cocktailSearchBloc;
  SearchControllerBloc drinkSearchBloc;

  Curve scaleDownCurve = new Interval(0.0, 0.3, curve: Curves.easeOut);
  Curve scaleUpCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideOutCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideInCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);

  ChangeNotifier myBarFilerNotifier;

  @override
  void initState() {
    super.initState();
    cocktailSearchBloc = new SearchControllerBloc();
    drinkSearchBloc = new SearchControllerBloc();
    menuController = new MenuController(
      vsync: this,
    )..addListener(() => setState(() {}));
    myBarFilerNotifier = ChangeNotifier();
  }

  @override
  void dispose() {
    menuController.dispose();
    cocktailSearchBloc.dispose();
    drinkSearchBloc.dispose();
    myBarFilerNotifier.dispose();
    super.dispose();
  }

  Page currentPage;

  createContentDisplay() {
    return zoomAndSlideContent(new Container(
        decoration: new BoxDecoration(color: Colors.white12),
        child: StreamBuilder<SearchState>(
            stream: currentPage == Page.CocktailList
                ? cocktailSearchBloc.searchState
                : drinkSearchBloc.searchState,
            initialData: SearchState(isEnabled: false, showProgress: false),
            builder: (context, snapshot) {
              return StoreConnector<AppState, _ViewModel>(
                  onInit: (store) {
                    currentPage = store.state.activePage;
                  },
                  converter: (store) => _ViewModel.fromStore(store),
                  builder: (context, vm) {
                    if (currentPage != vm.currentPage) {
                      if (currentPage == Page.CocktailList) {
                        cocktailSearchBloc.searchQuery.text = "";
                        cocktailSearchBloc.searchState.add(
                            SearchState(isEnabled: false, showProgress: false));
                      }

                      if (currentPage == Page.MyBar) {
                        drinkSearchBloc.searchQuery.text = "";
                        drinkSearchBloc.searchState.add(
                            SearchState(isEnabled: false, showProgress: false));
                      }

                      currentPage = vm.currentPage;
                    }

                    return Scaffold(
                      appBar: AppBar(
                          iconTheme: IconThemeData(color: Colors.purple),
                          backgroundColor: Colors.transparent,
                          elevation: 0.0,
                          leading: new IconButton(
                              icon: new Icon(Icons.menu),
                              onPressed: () {
                                menuController.toggle();
                              }),
                          title: snapshot.data.isEnabled
                              ? _buildSearchField(
                                  currentPage == Page.CocktailList
                                      ? cocktailSearchBloc
                                      : drinkSearchBloc,
                                  context)
                              : new Text(widget.contentScreen.title,
                                  style: new TextStyle(
                                    color: Colors.purple,
                                    fontFamily: 'bebas-neue',
                                    fontSize: 25.0,
                                  )),
                          actions: (currentPage == Page.CocktailList ||
                                  currentPage == Page.MyBar)
                              ? _buildActions(
                                  //       snapshot.data.isEnabled, vm, searchBloc)
                                  snapshot.data.isEnabled,
                                  vm,
                                  currentPage == Page.CocktailList
                                      ? cocktailSearchBloc
                                      : drinkSearchBloc)
                              : null),
                      body: Stack(children: <Widget>[
                        widget.contentScreen.content,
                        snapshot.data.showProgress
                            ? SizedBox(
                                child: LinearProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.yellowAccent)),
                                width: double.infinity,
                                height: 3.0,
                              )
                            : Container(
                                color: Theme.of(context).canvasColor,
                                width: double.infinity,
                                height: 0.0),
                      ]),
                    );
                  });
            })));
  }

  zoomAndSlideContent(Widget content) {
    var slidePercent, scalePercent;
    switch (menuController.state) {
      case MenuState.closed:
        slidePercent = 0.0;
        scalePercent = 0.0;
        break;
      case MenuState.open:
        slidePercent = 1.0;
        scalePercent = 1.0;
        break;
      case MenuState.opening:
        slidePercent = slideOutCurve.transform(menuController.percentOpen);
        scalePercent = scaleDownCurve.transform(menuController.percentOpen);
        break;
      case MenuState.closing:
        slidePercent = slideInCurve.transform(menuController.percentOpen);
        scalePercent = scaleUpCurve.transform(menuController.percentOpen);
        break;
    }

    final slideAmount = 275.0 * slidePercent;
    final contentScale = 1.0 - (0.2 * scalePercent);
    final cornerRadius = 10.0 * menuController.percentOpen;

    return new Transform(
      transform: new Matrix4.translationValues(slideAmount, 0.0, 0.0)
        ..scale(contentScale, contentScale),
      alignment: Alignment.centerLeft,
      child: new Container(
        decoration: new BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: const Color(0x44000000),
              offset: const Offset(0.0, 5.0),
              blurRadius: 20.0,
              spreadRadius: 10.0,
            ),
          ],
        ),
        child: new ClipRRect(
            borderRadius: new BorderRadius.circular(cornerRadius),
            child: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [widget.menuScreen, createContentDisplay()],
    );
  }

  //////////////
  void _clearSearchQuery(SearchControllerBloc bloc) {
    print("close search box");
    bloc.searchQuery.text = "";
  }

  Widget _buildSearchField(SearchControllerBloc bloc, BuildContext context) {
    return new TextField(
      controller: bloc.searchQuery,
      autofocus: true,
      decoration: InputDecoration(
        hintText: CrLocalization.of(context).searchHint,
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.purple),
      ),
      style: TextStyle(color: Colors.purple, fontSize: 16.0),
    );
  }

  List<Widget> _buildActions(
      bool isSearching, _ViewModel vm, SearchControllerBloc bloc) {
    if (isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (bloc.searchQuery == null || bloc.searchQuery.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery(bloc);
          },
        ),
      ];
    }

    return <Widget>[
      vm.currentPage == Page.CocktailList
          ? IconButton(
              icon: const Icon(Icons.local_bar),
              onPressed: () {
                vm.onSortByBarItems();
                myBarFilerNotifier.notifyListeners();
              })
          : Container(width: 0, height: 0),
      IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            ModalRoute.of(context)
                .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: () {
              bloc.searchState
                  .add(SearchState(isEnabled: false, showProgress: false));
              bloc.searchQuery.text = "";
            }));
            bloc.searchState
                .add(SearchState(isEnabled: true, showProgress: false));
          }),
    ];
  }
}

class ZoomScaffoldMenuController extends StatefulWidget {
  final ZoomScaffoldBuilder builder;

  ZoomScaffoldMenuController({
    this.builder,
  });

  @override
  ZoomScaffoldMenuControllerState createState() {
    return new ZoomScaffoldMenuControllerState();
  }
}

class ZoomScaffoldMenuControllerState
    extends State<ZoomScaffoldMenuController> {
  MenuController menuController;

  @override
  void initState() {
    super.initState();

    menuController = getMenuController(context);
    menuController.addListener(_onMenuControllerChange);
  }

  @override
  void dispose() {
    menuController.removeListener(_onMenuControllerChange);
    super.dispose();
  }

  getMenuController(BuildContext context) {
    final scaffoldState =
        context.ancestorStateOfType(new TypeMatcher<ZoomScaffoldState>())
            as ZoomScaffoldState;
    return scaffoldState.menuController;
  }

  _onMenuControllerChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, getMenuController(context));
  }
}

typedef Widget ZoomScaffoldBuilder(
    BuildContext context, MenuController menuController);

class Screen {
  final String title;
  final Widget content;

  Screen({
    this.title,
    this.content,
  });
}

typedef WidgetBuilderFunction<T> = Widget Function(
    BuildContext context, AppState state);

class MenuController extends ChangeNotifier {
  final TickerProvider vsync;
  final AnimationController _animationController;
  MenuState state = MenuState.closed;

  MenuController({
    this.vsync,
  }) : _animationController = new AnimationController(vsync: vsync) {
    _animationController
      ..duration = const Duration(milliseconds: 250)
      ..addListener(() {
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        switch (status) {
          case AnimationStatus.forward:
            state = MenuState.opening;
            break;
          case AnimationStatus.reverse:
            state = MenuState.closing;
            break;
          case AnimationStatus.completed:
            state = MenuState.open;
            break;
          case AnimationStatus.dismissed:
            state = MenuState.closed;
            break;
        }
        notifyListeners();
      });
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  get percentOpen {
    return _animationController.value;
  }

  open() {
    _animationController.forward();
  }

  close() {
    _animationController.reverse();
  }

  toggle() {
    if (state == MenuState.open) {
      close();
    } else if (state == MenuState.closed) {
      open();
    }
  }
}

enum MenuState {
  closed,
  opening,
  open,
  closing,
}
