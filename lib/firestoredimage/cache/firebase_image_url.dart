import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

class FireBaseUrl {
  final List<String> nodes;
  final String image;

  FireBaseUrl({@required this.nodes, @required this.image});

  StorageReference buildStorageReference() {
    StorageReference ref = FirebaseStorage.instance.ref();
    nodes.forEach((node) => ref = ref.child(node));
    ref = ref.child(image);
    return ref;
  }

  @override
  String toString() => image;
}
