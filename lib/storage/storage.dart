import 'dart:async';
import 'dart:io';
import 'package:cocktail_rush/model/cocktail.dart';
import 'package:cocktail_rush/model/content.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:cocktail_rush/model/ingredient.dart';
import 'package:cocktail_rush/model/cocktails_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CocktailsStorageImpl implements CocktailRushStorage {
  static final CocktailRushStorage _instance = CocktailsStorageImpl._internal();

  factory CocktailsStorageImpl() => _instance;

  CocktailsStorageImpl._internal();

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDB();
    }
    return _db;
  }

  Future initDB() async {
    Directory path = await getApplicationDocumentsDirectory();
    String dbPath = join(path.path, "cr.db");

    var db = await openDatabase(dbPath, version: 1, onCreate: this._create);
    return db;
  }

  Future _create(Database db, int version) async {
    await db.execute("CREATE TABLE ${Cocktail.table_name} ("
        "${Cocktail.field_id} INTEGER PRIMARY KEY, "
        "${Cocktail.field_name} TEXT NOT NULL, "
        "${Cocktail.field_alc} TEXT NOT NULL, "
        "${Cocktail.field_story} TEXT NOT NULL, "
        "${Cocktail.field_fav} INTEGER, "
        "${Cocktail.field_image} TEXT NOT NULL)"
        "");

    await db.execute("CREATE TABLE ${Drink.table_name} ("
        "${Drink.field_id} INTEGER PRIMARY KEY, "
        "${Drink.field_name} TEXT NOT NULL, "
        "${Drink.field_category} TEXT NOT NULL, "
        "${Drink.field_image} TEXT NOT NULL, "
        "${Drink.field_usage_count} TEXT NOT NULL, "
        "${Drink.field_in_bar} INTEGER, "
        "${Drink.field_story} TEXT NOT NULL)"
        "");

    await db.execute("CREATE TABLE ${Ingredient.table_name} ("
        "${Ingredient.field_id} INTEGER PRIMARY KEY, "
        "${Ingredient.field_measure} TEXT NOT NULL, "
        "${Ingredient.field_quantity} TEXT NOT NULL, "
        "${Ingredient.field_cocktailId} TEXT NOT NULL, "
        "${Ingredient.field_drinkId} TEXT NOT NULL, "
        " FOREIGN KEY (${Ingredient.field_cocktailId}) REFERENCES ${Cocktail.table_name} (${Cocktail.field_id}) ON DELETE NO ACTION ON UPDATE NO ACTION,"
        " FOREIGN KEY (${Ingredient.field_drinkId}) REFERENCES ${Drink.table_name} (${Drink.field_id}) ON DELETE NO ACTION ON UPDATE NO ACTION)"
        "");
  }

  @override
  Future<Content> insertOrUpdateContent(RepoContent repoContent) async {
    var dbClient = await db;

    ///insert or update Cocktails
    var storedCocktails = await fetchAllCocktails();

    Batch cocktailsBatch = dbClient.batch();
    repoContent.cocktails.forEach((loadedCocktail) {
      Cocktail exist = storedCocktails
          .firstWhere((c) => c.id == loadedCocktail.id, orElse: () => null);
      if (exist == null) {
        cocktailsBatch.insert(Cocktail.table_name, loadedCocktail.toMap());
      } else {
        cocktailsBatch.update(Cocktail.table_name, loadedCocktail.toMap(),
            where: "${Cocktail.field_id} = ?", whereArgs: [loadedCocktail.id]);
      }
    });

    var result = await cocktailsBatch.commit();
    if (result.isEmpty) {
      return null;
    }

    ///insert or update Drinks
    var storedDrinks = await fetchAllDrinks();

    final ingredientsList = List<Ingredient>();
    repoContent.cocktails.forEach((c) {
      c.ingredients.forEach((i) {
        i.cocktailId = c.id;
      });

      ingredientsList.addAll(c.ingredients);
    });

    Batch drinksBatch = dbClient.batch();
    repoContent.drinks.forEach((loadedDrink) {
      List<Ingredient> list = List.from(ingredientsList);
      list.retainWhere((it) => it.drinkId == loadedDrink.id);
      loadedDrink.usageCount = list.length.toString();

      Drink exist = storedDrinks.firstWhere((c) => c.id == loadedDrink.id,
          orElse: () => null);
      if (exist == null) {
        drinksBatch.insert(Drink.table_name, loadedDrink.toMap());
      } else {
        drinksBatch.update(Drink.table_name, loadedDrink.toMap(),
            where: "${Drink.field_id} = ?", whereArgs: [loadedDrink.id]);
      }
    });
    var result2 = await drinksBatch.commit();
    if (result2.isEmpty) {
      return null;
    }

    return fetchAllContent();
  }

  @override
  Future<List<Cocktail>> fetchAllCocktails() async {
    var dbClient = await db;
    var result =
        await dbClient.rawQuery('SELECT * FROM ${Cocktail.table_name}');

    List<Cocktail> cocktails = List();

    for (Map<String, dynamic> entry in result) {
      final cocktail = Cocktail.fromStorage(entry);
      var f = await Future.value((Cocktail c) async {
        c.ingredients = await _fetchIngredientsFor(c.id);
      });
      await f(cocktail).whenComplete(() {
        print("Fetched from Storage $cocktail");
        cocktails.add(cocktail);
      }).catchError(print);
    }
    return cocktails;
  }

  Future<List<Ingredient>> _fetchIngredientsFor(String cocktailId) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery('SELECT '
        '${Ingredient.field_measure}, '
        '${Ingredient.table_name}.${Ingredient.field_cocktailId}, '
        '${Ingredient.field_quantity}, '
        '${Ingredient.field_drinkId}, '
        '${Drink.table_name}.${Drink.field_id}, '
        '${Drink.field_name}, '
        '${Drink.field_image}, '
        '${Drink.field_category}, '
        '${Drink.field_usage_count}, '
        '${Drink.field_in_bar}, '
        '${Drink.field_story} '
        'FROM ${Ingredient.table_name} INNER JOIN ${Drink.table_name} ON ${Drink.table_name}.${Drink.field_id} = ${Ingredient.table_name}.${Ingredient.field_drinkId} '
        'WHERE ${Ingredient.table_name}.${Ingredient.field_cocktailId} == $cocktailId');
    if (result.isEmpty) {
      return List<Ingredient>();
    }
    List<Ingredient> ingredients = result.map((json) {
      return Ingredient.fromStorage(json);
    }).toList();
    return ingredients;
  }

  @override
  Future<Content> storeAllContent(RepoContent repoContent) async {
    var dbClient = await db;
    Batch cocktailsBatch = dbClient.batch();
    repoContent.cocktails.forEach((c) {
      cocktailsBatch.insert(Cocktail.table_name, c.toMap());
    });

    var result = await cocktailsBatch.commit();
    if (result.isEmpty) {
      return null;
    }
    Batch ingredientsBatch = dbClient.batch();
    final ingredientsList = List<Ingredient>();
    repoContent.cocktails.forEach((c) {
      c.ingredients.forEach((i) {
        i.cocktailId = c.id;
      });

      ingredientsList.addAll(c.ingredients);
    });

    ingredientsList.forEach((i) {
      ingredientsBatch.insert(Ingredient.table_name, i.toMap());
    });

    var result2 = await ingredientsBatch.commit();
    if (result2.isEmpty) {
      return null;
    }

    Batch drinkBatch = dbClient.batch();

    repoContent.drinks.forEach((drink) {
      List<Ingredient> list = List.from(ingredientsList);
      list.retainWhere((it) => it.drinkId == drink.id);
      drink.usageCount = list.length.toString();

      drinkBatch.insert(Drink.table_name, drink.toMap());
    });

    var result3 = await drinkBatch.commit();
    if (result3.isEmpty) {
      return null;
    }

    return fetchAllContent();
  }

  @override
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  @override
  Future<List<Cocktail>> fetchCocktailsByName(String name) async {
    var dbClient = await db;

    final result = await dbClient.rawQuery(
        "SELECT * FROM ${Cocktail.table_name}${name.isEmpty ? "" : " WHERE ${Cocktail.field_name} LIKE '%$name%'"}");

    List<Cocktail> cocktails = List();

    for (Map<String, dynamic> entry in result) {
      final cocktail = Cocktail.fromStorage(entry);
      var f = await Future.value((Cocktail c) async {
        c.ingredients = await _fetchIngredientsFor(c.id);
      });
      await f(cocktail).whenComplete(() {
        print("Fetched from Storage $cocktail");
        cocktails.add(cocktail);
      });
    }
    return cocktails;
  }

  @override
  Future<Content> fetchAllContent() async {
    List<Cocktail> cocktails = await fetchAllCocktails();
    List<Drink> drinks = await fetchAllDrinks();
    final content = Content(cocktails: cocktails, drinks: drinks);
    return content;
  }

  @override
  Future<List<Drink>> fetchAllDrinks() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery('SELECT * FROM ${Drink.table_name}');

    List<Drink> drinks = List();

    for (Map<String, dynamic> entry in result) {
      final drink = Drink.fromMap(entry);
      print("Fetched from Storage $drink");
      drinks.add(drink);
    }
    return drinks;
  }

  @override
  Future updateDrinkInBarContent(Drink drink) async {
    var dbClient = await db;
    dbClient.update(Drink.table_name, drink.toMap(),
        where: "${Drink.field_id} = ?", whereArgs: [drink.id]);
  }

  @override
  Future<int> updateCocktail(Cocktail cocktail) async {
    var dbClient = await db;
    return dbClient.update(Cocktail.table_name, cocktail.toMap(),
        where: "${Cocktail.field_id} = ?", whereArgs: [cocktail.id]);
  }

  @override
  Future clear() {
    // TODO: implement clear
    return null;
  }
}

abstract class CocktailRushStorage {
  Future<Content> insertOrUpdateContent(RepoContent repoContent);

  Future<Content> storeAllContent(RepoContent repoContent);

  Future<Content> fetchAllContent();

  Future updateDrinkInBarContent(Drink drink);

  Future<int> updateCocktail(Cocktail cocktail);

  Future<List<Cocktail>> fetchAllCocktails();

  Future<List<Drink>> fetchAllDrinks();

  Future<List<Cocktail>> fetchCocktailsByName(String name);

  Future clear();

  Future close();
}
