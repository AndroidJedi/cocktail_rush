import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:flutter/material.dart';

class CategorySelectorWidget extends StatelessWidget {
  final Category selectedSearchFilter;
  final Function(Category value) onCategorySelected;

  CategorySelectorWidget({this.selectedSearchFilter, this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Radio(
                value: Category.ALC,
                groupValue: selectedSearchFilter,
                onChanged: onCategorySelected,
              ),
              new Text(
                CrLocalization.of(context).filterItemAlc,
                style: new TextStyle(fontSize: 16.0, color: Colors.purple),
              ),
              new Radio(
                value: Category.NO_ALC,
                groupValue: selectedSearchFilter,
                onChanged: onCategorySelected,
              ),
              new Text(
                CrLocalization.of(context).filterItemMixers,
                style: new TextStyle(fontSize: 16.0, color: Colors.purple),
              ),
              new Radio(
                value: Category.OTHER,
                groupValue: selectedSearchFilter,
                onChanged: onCategorySelected,
              ),
              new Text(
                CrLocalization.of(context).filterItemOther,
                style: new TextStyle(fontSize: 16.0, color: Colors.purple),
              ),
            ]),
      ),
    );
  }
}

class Category {
  final value;

  const Category._internal(this.value);

  static const ALC = const Category._internal('alc');
  static const NO_ALC = const Category._internal('mix');
  static const OTHER = const Category._internal('oth');

  @override
  String toString() => value;
}
