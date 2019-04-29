import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/model/drink.dart';
import 'package:flutter/material.dart';

class Ingredient {
  String drinkId, cocktailId, quantity, measure, id;
  Drink drink;

  Ingredient.fromRepository(json)
      :
        cocktailId = json[field_cocktailId].toString(),
        drinkId    = json[field_drinkId].toString(),
        quantity   = json[field_quantity].toString(),
        measure    = json[field_measure].toString(),
        id         = json[field_id].toString();

  Ingredient.fromStorage(json)
      :
        cocktailId = json[field_cocktailId].toString(),
        drinkId    = json[field_drinkId].toString(),
        quantity   = json[field_quantity].toString(),
        measure    = json[field_measure].toString(),
        id         = json[field_id].toString(),
        drink      = Drink.fromStorageToIngredient(json);


  Map<String, dynamic> toMap() => {
    field_id: id,
    field_drinkId: drinkId,
    field_quantity: quantity,
    field_cocktailId: cocktailId,
    field_measure: measure
  };

  @override
  bool operator ==(other) {
    return
        drinkId == other.drinkId &&
        quantity == other.quantity &&
        measure == other.measure;
        // && id == other.id;
        // && drink == other.drink;
  }

  String measuredQuantity(BuildContext context){
    String measuredQuantity = quantity;

    if(measure == '1'){
      measuredQuantity += CrLocalization.of(context).dosageMl;
    } else if (measure == '2'){
      measuredQuantity += CrLocalization.of(context).dosageGr;
    } else if (measure == '3'){
      measuredQuantity += CrLocalization.of(context).dosagePc;
    }

    return measuredQuantity;
  }

  @override
  int get hashCode =>
          drinkId.hashCode +
          quantity.hashCode +
          measure.hashCode;
        //  id.hashCode;
       //+ drink.hashCode;

  @override
  String toString() =>
      'Ingredient {drinkId: $drinkId, quantity: $quantity, measure: $measure, id: $id}';

  static final columns = [
    field_id,
    field_quantity,
    field_measure,
    field_drinkId,
    field_cocktailId
  ];

  static const String table_name = "ingredients";
  static const String field_id = "id";
  static const String field_quantity = "quantity";
  static const String field_measure = "meassure";
  static const String field_drinkId = "drinkId";
  static const String field_cocktailId = "cocktailId";
}