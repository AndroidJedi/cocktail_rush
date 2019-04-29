import 'package:cocktail_rush/model/ingredient.dart';
import 'package:cocktail_rush/model/generic.dart';
import 'package:cocktail_rush/model/utils.dart';

class Cocktail implements Searchable, Selectable {
  String id, name, alc, image, story;
  List<Ingredient> ingredients;

  //helper var for sort
  int drinksInBar = 0;
  bool isFav = false;

  Cocktail.fromRepository(json)
      : id = json["id"].toString(),
        name = json["name"],
        alc = json["alc"].toString(),
        image = json["image"],
        story = json["story"],
        ingredients = List.from(json["ingredients"])
            .map((json) => Ingredient.fromRepository(json))
            .toList();

  Cocktail(this.id, this.name, this. alc, this.image, this.story, this.ingredients, this.drinksInBar, this.isFav);

  static Map<String, dynamic> stub() => {
        Cocktail.field_id: -1,
        Cocktail.field_name: "stubName",
        Cocktail.field_alc: "stubAlc",
        Cocktail.field_image: "stubImage",
        Cocktail.field_fav: 0,
      };

  Cocktail.fromStorage(json)
      : id = json["id"].toString(),
        name = json["name"],
        alc = json["alc"].toString(),
        story = json["story"],
        image = json["image"],
        isFav = (json[field_fav] == 1 ? true : false) ?? false;

  Map<String, dynamic> toMap() => {
        Cocktail.field_id: id,
        Cocktail.field_name: name,
        Cocktail.field_alc: alc,
        Cocktail.field_image: image,
        Cocktail.field_story: story,
        Cocktail.field_fav: (isFav ? 1 : 0) ?? false
      };

  @override
  String toString() =>
      'Cocktail {id: $id, name: $name, image: $image, story: $story, ingredients: $ingredients, favourite: $isFav}';

  static final columns = [
    Cocktail.field_id,
    Cocktail.field_name,
    Cocktail.field_alc,
    Cocktail.field_image,
    Cocktail.field_story,
    Cocktail.field_fav
  ];

  @override
  bool operator ==(other) {
    return id == other.id &&
        name == other.name &&
        alc == other.alc &&
        image == other.image &&
        deepEquals(ingredients, other.ingredients);
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ image.hashCode ^ deepHash(ingredients);

  static const String table_name = "cocktails";
  static const String field_id = "id";
  static const String field_name = "name";
  static const String field_alc = "alc";
  static const String field_image = "image";
  static const String field_story = "story";
  static const String field_ingredients = "ingredients";
  static const String field_fav = "favourite";

  @override
  String getItemName() => name;

  @override
  bool isSelected() => isFav;
}
