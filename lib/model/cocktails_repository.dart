import 'dart:async';

import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:flutter/material.dart';

abstract class CocktailRushRepository {

  Future<RepoContent> allContent(Locale locale);

}

class RepoContent{
  List<Cocktail> cocktails;
  List<Drink> drinks;

  RepoContent(this.cocktails, this.drinks);

}