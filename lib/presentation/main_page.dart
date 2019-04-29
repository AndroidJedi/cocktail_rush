import 'package:cocktail_rush/actions/actions.dart';
import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/content.dart';
import 'package:cocktail_rush/model/generic.dart';
import 'package:cocktail_rush/presentation/cocktailpage/cocktails_page.dart';
import 'package:cocktail_rush/presentation/favPage/fav_page.dart';
import 'package:cocktail_rush/presentation/menu/menu_screen.dart';
import 'package:cocktail_rush/presentation/menu/zoom_scaffold.dart';
import 'package:cocktail_rush/presentation/mybarpage/my_bar_page.dart';
import 'package:cocktail_rush/presentation/shakerpage/shaker_page.dart';
import 'package:cocktail_rush/presentation/supportpage/support_page.dart';
import 'package:cocktail_rush/presentation/widgets/loading_indicator.dart';
import 'package:cocktail_rush/presentation/widgets/snack_notifier_widget.dart';
import 'package:cocktail_rush/selectors/selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

Widget Function(BuildContext context, Key key) pageBuilder;

class _MainPageState extends State<MainPage> {
  final menu = new Menu(
    items: [
      new MenuItem(
        page: Page.CocktailList,
        title: (context) => CrLocalization.of(context).menuItemCocktails,
      ),
      new MenuItem(
        page: Page.MyBar,
        title: (context) => CrLocalization.of(context).menuItemMyBar,
      ),
      new MenuItem(
        page: Page.Fav,
        title: (context) => CrLocalization.of(context).menuFavBar,
      ),
      new MenuItem(
        page: Page.Shaker,
        title: (context) => CrLocalization.of(context).menuShaker,
      ),
    ],
  );

  final bgKey = ObjectKey("bgKey");
  final favKey = ObjectKey("favKey");
  final fgKey = ObjectKey("fgKey");
  final shakerKey = ObjectKey("shakerKey");

  Screen _buildPages(Content content, List<Cocktail> sortedCocktails,
      Page activePage, BuildContext context) {
    List<Cocktail> cl0 =
        sortedCocktails.length == 0 ? content.cocktails : sortedCocktails;
    List<ComparableSortedCocktail> cl1 = List();
    cl0.forEach((c) {
      cl1.add(ComparableSortedCocktail.from(c));
    });
    final cocktailPage = CocktailsPage(
      cocktails: cl1,
    );

    final myBarPage = MyBarPage(
      drinks: content.drinks,
    );

    final favPage = FavPage();

    Widget foreground;
    String title;
    List<Widget> children = [];

    switch (activePage) {
      case Page.CocktailList:
        children.add(Opacity(key: bgKey, opacity: 0.0, child: myBarPage));
        children.add(Opacity(key: favKey, opacity: 0.0, child: favPage));
        children.add(Opacity(
            key: shakerKey,
            opacity: 0.0,
            child: ShakerPage(foreground: false)));
        foreground = Opacity(key: fgKey, opacity: 1.0, child: cocktailPage);
        title = CrLocalization.of(context).menuItemCocktails;
        break;
      case Page.MyBar:
        children.add(Opacity(key: fgKey, opacity: 0.0, child: cocktailPage));
        children.add(Opacity(key: favKey, opacity: 0.0, child: favPage));
        children.add(Opacity(
            key: shakerKey,
            opacity: 0.0,
            child: ShakerPage(foreground: false)));
        foreground = Opacity(key: bgKey, opacity: 1.0, child: myBarPage);
        title = CrLocalization.of(context).menuItemMyBar;
        break;
      case Page.Fav:
        children.add(Opacity(key: fgKey, opacity: 0.0, child: cocktailPage));
        children.add(Opacity(key: bgKey, opacity: 0.0, child: myBarPage));
        children.add(Opacity(
            key: shakerKey,
            opacity: 0.0,
            child: ShakerPage(foreground: false)));
        foreground = Opacity(key: favKey, opacity: 1.0, child: favPage);
        title = CrLocalization.of(context).menuFavBar;
        break;
      case Page.Shaker:
        children.add(Opacity(key: fgKey, opacity: 0.0, child: cocktailPage));
        children.add(Opacity(key: bgKey, opacity: 0.0, child: myBarPage));
        children.add(Opacity(key: favKey, opacity: 0.0, child: favPage));
        foreground = Opacity(
            key: shakerKey, opacity: 1.0, child: ShakerPage(foreground: true));
        title = CrLocalization.of(context).menuShaker;
        break;
      case Page.Promo:
        //    title = CrLocalization.of(context).menuPromo;
        break;
    }

    children.add(foreground);
    Screen screen = Screen(title: title, content: Stack(children: children));
    return screen;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: _ViewModel.fromStore,
      builder: (context, vm) {
        return SnackNotifierWidget(
          item: SelectableImpl(vm.showImageLoading &&  !vm.isContentLoading),
          child: _buildMainContent(vm),
          getActionText: () =>
              CrLocalization.of(context).cocktailsPageImagesLoadingSnackMessage,
          onAnimationCompleted: () {},
        );
      },
    );
  }

  Widget _buildMainContent(_ViewModel vm) {
    return Container(
        decoration:
            BoxDecoration(color: Theme.of(context).dialogBackgroundColor),
        child: vm.isContentLoading
            ? LoadingIndicator()
            : ZoomScaffold(
                menuScreen: new MenuScreen(
                    menu: menu,
                    selectedPage: vm.activePage,
                    onMenuItemSelected: vm.onMenuItemSelected),
                contentScreen: _buildPages(
                    vm.content, vm.sortedCocktails, vm.activePage, context),
              ));
  }
}

class _ViewModel {
  final bool isContentLoading;
  final bool showImageLoading;
  final Page activePage;
  final Content content;
  final List<Cocktail> sortedCocktails;
  final Function(Page) onMenuItemSelected;
  final Function(Locale) loadContentForLocale;

  _ViewModel({
    @required this.onMenuItemSelected,
    @required this.loadContentForLocale,
    @required this.showImageLoading,
    @required this.isContentLoading,
    @required this.sortedCocktails,
    @required this.content,
    @required this.activePage,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      onMenuItemSelected: (page) => store.dispatch(SelectPageAction(page)),
      loadContentForLocale: (locale) =>
          store.dispatch(LoadContentFromStorageAction(locale)),
      isContentLoading: store.state.content.cocktails.isEmpty,
      content: store.state.content,
      sortedCocktails: store.state.sortedCocktails,
      activePage: activeTabSelector(store.state),
      showImageLoading: store.state.showLoadingImages,
    );
  }
}

enum Page { CocktailList, MyBar, Fav, Shaker, Promo }
