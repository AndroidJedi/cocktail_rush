import 'package:cocktail_rush/keys/keys.dart';
import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/presentation/cocktaildetailpage/cocktail_detail_page.dart';
import 'package:cocktail_rush/presentation/routes/fade_route.dart';
import 'package:cocktail_rush/presentation/cocktailpage/cocktail_list_item.dart';
import 'package:cocktail_rush/presentation/search/search_bloc.dart';
import 'package:flutter/material.dart';

class CocktailList extends StatefulWidget {
  final SearchBloc<Cocktail> bloc;
  final bool upScroll;

  CocktailList({@required this.bloc, this.upScroll, Key key}) : super(key: key);

  @override
  _CocktailListState createState() => _CocktailListState();
}

class _CocktailListState extends State<CocktailList> {
  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void didUpdateWidget(CocktailList oldWidget) {
    if (widget.upScroll) {
      _scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 350), curve: Curves.linear);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Cocktail>>(
      stream: widget.bloc.filteredList,
      initialData: widget.bloc.filteredList.value,
      builder: (context, snapshot) => _buildListView(snapshot.data),
    );
  }

  ListView _buildListView(List<Cocktail> cocktailList) {
    return ListView.builder(
      controller: _scrollController,
      key: Keys.cocktailList,
      padding: EdgeInsets.all(10.0),
      itemCount: cocktailList == null ? 0 : cocktailList.length,
      itemBuilder: (BuildContext context, int index) {
        final cocktail = cocktailList[index];
        return CocktailItem(
          key: Keys.cocktailItem(cocktail.id),
          cocktail: cocktail,
          onTap: () => _onTodoTap(context, cocktail),
        );
      },
    );
  }

  _onTodoTap(BuildContext context, Cocktail cocktail) {
    Navigator.of(context).push(FadeRoute(
      duration: Duration(milliseconds: 200),
      builder: (_) => CocktailDetailPage(cocktail: cocktail, hero: true),
    ));
  }
}
