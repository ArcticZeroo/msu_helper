import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TableName {
  static const diningHallMenu = 'diningHallMenu';
  static const jsonCache = 'jsonCache';
  static const userSettings = 'userSettings';
}

Map<String, String> tables = {
  '${TableName.diningHallMenu}': 'searchName TEXT, date TEXT, meal INTEGER, retrieved INTEGER, json TEXT',
  '${TableName.jsonCache}': 'name TEXT PRIMARY KEY, json TEXT, retrieved INTEGER',
  // Store settings value as text so it can be anything... will be later converted
  '${TableName.userSettings}': 'name TEXT PRIMARY KEY, value TEXT'
};

typedef OnReadyCallback();

class MainDatabase {
  static final MainDatabase _mainDb = MainDatabase._internal();
  static List<OnReadyCallback> _onReadyCallbacks = new List();

  static Future<Database> getDbInstance() async {
    if (_mainDb.db != null) {
      return _mainDb.db;
    }

    Completer<Database> completer = new Completer();

    OnReadyCallback callback = () {
      completer.complete(_mainDb.db);
    };

    _onReadyCallbacks.add(callback);

    return completer.future;
  }

  factory MainDatabase() {
    return _mainDb;
  }

  MainDatabase._internal() {
    init().catchError(print);
  }

  Database db;

  Future<String> get _localPath async {
    var directory = await getApplicationDocumentsDirectory();

    String pathName = join(directory.path, 'msuHelper.db');

    bool exists = await directory.exists();

    if (!exists) {
      await directory.create(recursive: true);
    }

    return pathName;
  }

  Future _onOpen(Database db) async {
    print('Database opened');

    for (MapEntry<String, String> table in tables.entries) {
      await db.execute('CREATE TABLE IF NOT EXISTS ${table.key} (${table.value})');
    }
  }

  Future init() async {
    print('Initializing database...');
    db = await openDatabase(await _localPath, onOpen: _onOpen);

    for (OnReadyCallback callback in _onReadyCallbacks) {
      await callback();
    }
  }
}