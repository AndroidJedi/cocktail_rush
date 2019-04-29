import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/model/generic.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

class Drink implements Searchable, Selectable {
  String id;
  String image;
  String name;
  String category;
  String story;
  String usageCount;
  bool inBar = false;

  Drink.fromMap(json)
      : id = json[field_id].toString(),
        name = json[field_name],
        image = json[field_image],
        story = json[field_story],
        category = json[field_category],
        usageCount = json[field_usage_count] ?? "-1",
        inBar = (json[field_in_bar] == 1 ? true : false) ?? false;

  Drink.fromStorageToIngredient(json)
      : id = json[field_id].toString(),
        name = json[field_name],
        image = json[field_image],
        story = json[field_story],
        category = json[field_category],
        usageCount = json[field_usage_count],
        inBar = (json[field_in_bar] == 1 ? true : false) ?? false;

  Map<String, dynamic> toMap() => {
        field_id: id,
        field_name: name,
        field_image: image,
        field_story: story,
        field_category: category,
        field_usage_count: usageCount ?? "-1",
        field_in_bar: (inBar ? 1 : 0) ?? false
      };

  @override
  String toString() =>
      'Drink {id: $id, name: $name, image: $image, story: $story, category: $category, usage count: $usageCount, inBar: $inBar}';

  //keys
  static const String table_name = "drinks";
  static const String field_id = "id";
  static const String field_name = "name";
  static const String field_image = "image";
  static const String field_category = "category";
  static const String field_story = "story";
  static const String field_usage_count = "usage_count";
  static const String field_in_bar = "in_bar";

  @override
  bool operator ==(other) {
    return id == other.id &&
        name == other.name &&
        image == other.image &&
        category == other.category &&
        story == other.story;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      image.hashCode ^
      category.hashCode ^
      story.hashCode;

  String usedInNumberOfCocktails(BuildContext context) {
    if (usageCount == "1") {
      return sprintf(
          CrLocalization.of(context).cocktailsCountSingle, [usageCount]);
    } else {
      return sprintf(
          CrLocalization.of(context).cocktailsCountMultiple, [usageCount]);
    }
  }

  @override
  String getItemName() => name;

  @override
  bool isSelected() => inBar;

}
