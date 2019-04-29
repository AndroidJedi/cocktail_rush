import 'dart:async';

import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/model/cocktails_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FirebaseCocktailRushRepository implements CocktailRushRepository {
  static const String path_cocktails = 'cocktails';
  static const String path_drinks = 'drinks';

  final FirebaseDatabase database;
  DatabaseReference _drinksRefRu;
  DatabaseReference _drinksRefEn;
  DatabaseReference _cocktailsRefRu;
  DatabaseReference _cocktailsRefEn;

  FirebaseCocktailRushRepository(this.database) {
    _drinksRefRu = database.reference().child("ru").child(path_drinks);
    _drinksRefEn = database.reference().child("en").child(path_drinks);
    _cocktailsRefRu = database.reference().child("ru").child(path_cocktails);
    _cocktailsRefEn = database.reference().child("en").child(path_cocktails);
  }

  Future<List<Cocktail>> _cocktails(Locale locale) async {

    DatabaseReference _cocktailsRef;
    if (locale.languageCode == "ru") {
      _cocktailsRef = _cocktailsRefRu;
    } else {
      _cocktailsRef = _cocktailsRefEn;
    }
    return await _cocktailsRef.once().then((DataSnapshot snapshot) {
      List<Cocktail> list = List();
      for (final item in (snapshot.value as List)) {
        final cocktail = Cocktail.fromRepository(item);
        list.add(cocktail);
        print("Fetched from Repository $cocktail");
      }
      return list;
    }).catchError((e) {
      print(e);
      return null;
    });
  }

  Future<List<Drink>> _drinks(Locale locale) async {
    DatabaseReference _drinksRef;
    if (locale.languageCode == "ru") {
      _drinksRef = _drinksRefRu;
    } else {
      _drinksRef = _drinksRefEn;
    }
    return await _drinksRef.once().then((DataSnapshot snapshot) {
      List<Drink> list = List();
      for (final item in (snapshot.value as List)) {
        final drink = Drink.fromMap(item);
        list.add(drink);
        print("Fetched from Repository $drink");
      }
      return list;
    }).catchError((e) {
      print(e);
      return null;
    });
  }

  @override
  Future<RepoContent> allContent(Locale locale) async {
    final drinkList = await _drinks(locale);
    final cocktailList = await _cocktails(locale);
    return RepoContent(cocktailList, drinkList);
  }
}
