

import 'package:cocktail_rush/actions/actions.dart';

bool showImagesLoad(bool showImagesLoad, dynamic action) {
  if (action is ShowLoadImagesAction) {
    return true;
  }

  return showImagesLoad;
}
