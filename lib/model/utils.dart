
import 'package:collection/collection.dart';

Function deepEquals = const DeepCollectionEquality.unordered().equals;
Function deepHash = const DeepCollectionEquality.unordered().hash;
