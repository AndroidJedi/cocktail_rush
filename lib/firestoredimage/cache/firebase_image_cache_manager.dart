import 'dart:convert';
import 'dart:io';

import 'package:cocktail_rush/firestoredimage/cache/firebase_image_cache_object.dart';
import 'package:cocktail_rush/firestoredimage/cache/firebase_image_url.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class FirebaseCacheManager {
  static const _keyCacheData = "lib_cached_image_data";
  static FirebaseCacheManager _instance;
  static bool showDebugLogs = false;
  static Lock _lock = new Lock();
  SharedPreferences _prefs;
  Map<String, FireBaseCacheObject> _cacheData;
  Lock _storeLock = new Lock();

  bool _isStoringData = false;
  bool _shouldStoreDataAgain = false;

  static Future<FirebaseCacheManager> getInstance() async {
    if (_instance == null) {
      await _lock.synchronized(() async {
        if (_instance == null) {
          // keep local instance till it is fully initialized
          var newInstance = new FirebaseCacheManager._();
          await newInstance._init();
          _instance = newInstance;
        }
      });
    }
    return _instance;
  }

  FirebaseCacheManager._();

  ///Shared preferences is used to keep track of the information about the files
  Future _init() async {
    _prefs = await SharedPreferences.getInstance();
    _getSavedCacheDataFromPreferences();
    // _getLastCleanTimestampFromPreferences();
  }

  _getSavedCacheDataFromPreferences() {
    //get saved cache data from shared prefs
    var jsonCacheString = _prefs.getString(_keyCacheData);
    _cacheData = new Map();
    if (jsonCacheString != null) {
      Map jsonCache = const JsonDecoder().convert(jsonCacheString);
      jsonCache.forEach((key, data) {
        if (data != null) {
          _cacheData[key] = new FireBaseCacheObject.fromMap(key, data);
        }
      });
    }
  }

  ///Get the file from the cache or online. Depending on availability and age
  Future<File> getFile(FireBaseUrl url) async {
    String log = "[Flutter Cache Manager] Loading $url";

    if (!_cacheData.containsKey(url.image)) {
      await _lock.synchronized(() {
        if (!_cacheData.containsKey(url)) {
          _cacheData[url.image] = new FireBaseCacheObject(url.image);
        }
      });
    }

    var cacheObject = _cacheData[url.image];
    await cacheObject.lock.synchronized(() async {
      // Set touched date to show that this object is being used recently
      cacheObject.touch();

      var filePath = await cacheObject.getFilePath();
      //If we have never downloaded this file, do download
      // if (filePath == null) {

      var cachedFile = new File(filePath);
      var cachedFileExists = await cachedFile.exists();
      if (!cachedFileExists) {
        log = "$log\nDownloading because file does not exist.";
        print(log);
        var newCacheData = await _downloadFile(url, cacheObject.lock,
            relativePath: cacheObject.relativePath);
        if (newCacheData != null) {
          _cacheData[url.image] = newCacheData;
        }

        //  log = "$log\Cache file valid till ${_cacheData[url].validTill?.toIso8601String() ?? "only once.. :("}";
       return;
      }

//        log = "$log\nDownloading for first time.";
//        var newCacheData = await _downloadFile(url, cacheObject.lock);
//        if (newCacheData != null) {
//          _cacheData[url.image] = newCacheData;
//        }
//        return;
      //   }

/*      //If file is removed from the cache storage, download again
      var cachedFile = new File(filePath);
      var cachedFileExists = await cachedFile.exists();
      if (!cachedFileExists) {
        log = "$log\nDownloading because file does not exist.";
        var newCacheData = await _downloadFile(url, cacheObject.lock,
            relativePath: cacheObject.relativePath);
        if (newCacheData != null) {
          _cacheData[url.image] = newCacheData;
        }

        //  log = "$log\Cache file valid till ${_cacheData[url].validTill?.toIso8601String() ?? "only once.. :("}";
        return;
      }*/
//      //If file is old, download if server has newer one
//      if (cacheObject.validTill == null ||
//          cacheObject.validTill.isBefore(new DateTime.now())) {
//        log = "$log\nUpdating file in cache.";
//        var newCacheData = await _downloadFile(url, headers, cacheObject.lock,
//            relativePath: cacheObject.relativePath, eTag: cacheObject.eTag);
//        if (newCacheData != null) {
//          _cacheData[url] = newCacheData;
//        }
//        log =
//            "$log\nNew cache file valid till ${_cacheData[url].validTill?.toIso8601String() ?? "only once.. :("}";
//        return;
//      }
//      log =
//          "$log\nUsing file from cache.\nCache valid till ${_cacheData[url].validTill?.toIso8601String() ?? "only once.. :("}";
    });

    //If non of the above is true, than we don't have to download anything.
    _save();
    if (showDebugLogs) print(log);

    var path = await _cacheData[url.image].getFilePath();
    if (path == null) {
      return null;
    }
    return new File(path);
  }

  ///Store all data to shared preferences
  _save() async {
    if (!(await _canSave())) {
      return;
    }

    // await _cleanCache();
    await _saveDataInPrefs();
  }

  Future<bool> _canSave() async {
    return await _storeLock.synchronized(() {
      if (_isStoringData) {
        _shouldStoreDataAgain = true;
        return false;
      }
      _isStoringData = true;
      return true;
    });
  }

  _saveDataInPrefs() async {
    Map json = new Map();

    await _lock.synchronized(() {
      _cacheData.forEach((key, cache) {
        json[key] = cache?.toMap();
      });
    });

    _prefs.setString(_keyCacheData, const JsonEncoder().convert(json));

    if (await _shouldSaveAgain()) {
      await _saveDataInPrefs();
    }
  }

  Future<bool> _shouldSaveAgain() async {
    return await _storeLock.synchronized(() {
      if (_shouldStoreDataAgain) {
        _shouldStoreDataAgain = false;
        return true;
      }
      _isStoringData = false;
      return false;
    });
  }

  ///Download the file from the url
  Future<FireBaseCacheObject> _downloadFile(FireBaseUrl url, Object lock,
      {String relativePath}) async {
    var newCache = new FireBaseCacheObject(url.image, lock: lock);
    newCache.setRelativePath(relativePath);

    var filePath = await newCache.getFilePath();
    File file = File(filePath);
    var folder = new File(filePath).parent;
    if (!(await folder.exists())) {
      folder.createSync(recursive: true);
    }

    final StorageReference ref = url.buildStorageReference();
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);

    await downloadTask.future.catchError((_) => newCache = null);

    return newCache;
  }

  void removeFromCache(FireBaseUrl url) async {
    FireBaseCacheObject removed = _cacheData.remove(url.image);
    if (removed != null) {
      var filePath = await removed.getFilePath();
      var cachedFile = new File(filePath);
      var cachedFileExists = await cachedFile.exists();
      if (cachedFileExists) {
        await cachedFile.delete();
      }
    }
    _saveDataInPrefs();
  }
}
