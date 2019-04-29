import 'package:flutter/widgets.dart';

class Keys{
  static final cocktailList = const Key('__cocktailList__');
  static final ingredientList = const Key('__ingredientList__');
  static final cocktailItem = (String id) => Key('__cocktailItem__$id');
  static final drinkItem = (int id) => Key('__drinkItem__$id');
}