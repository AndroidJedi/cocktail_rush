import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

class FireBaseCacheObject {
  static const _keyFilePath = "relativePath";
  static const _keyTouched = "touched";

  Future<String> getFilePath() async {
    if (relativePath == null) {
      return null;
    }
    Directory directory = await getTemporaryDirectory();
    return directory.path + relativePath;
  }

  String get relativePath {
    if (_map.containsKey(_keyFilePath)) {
      return _map[_keyFilePath];
    }
    return null;
  }

  Lock lock;
  Map _map;
  String fileName;
  DateTime touched;

  FireBaseCacheObject(String fileName, {this.lock}) {
    this.fileName = fileName;
    _map = new Map();
    setRelativePath('/$fileName');
    touch();
    if (lock == null) {
      lock = new Lock();
    }
  }

  touch() {
    touched = new DateTime.now();
    _map[_keyTouched] = touched.millisecondsSinceEpoch;
  }

  setRelativePath(String path) {
    _map[_keyFilePath] = path;
  }

  FireBaseCacheObject.fromMap(String fileName, Map map, {this.lock}) {
    this.fileName = fileName;
    _map = map;

    if (_map.containsKey(_keyTouched)) {
      touched = new DateTime.fromMillisecondsSinceEpoch(_map[_keyTouched]);
    } else {
      touch();
    }
    if (lock == null) {
      lock = new Lock();
    }
  }

  Map toMap() {
    return _map;
  }
}
