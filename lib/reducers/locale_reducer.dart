import 'package:cocktail_rush/actions/actions.dart';
import 'package:flutter/material.dart';

Locale localeReducer(Locale locale, dynamic action) {
  if (action is UpdateStoreLocaleAction) {
    return action.locale;
  }

  return locale;
}
