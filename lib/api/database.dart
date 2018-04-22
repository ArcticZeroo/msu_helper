import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class TableName {
  static const diningHalls = 'diningHalls';
  static const diningHallMenu = 'diningHallMenu';
  static const jsonCache = 'jsonCache';
}

Map<String, String> tables = {
  '${TableName.diningHalls}': 'searchName TEXT PRIMARY KEY, json TEXT',
  '${TableName.diningHallMenu}': 'searchName TEXT, date TEXT, meal INTEGER, retrieved INTEGER, json TEXT',
  '${TableName.jsonCache}': 'name TEXT PRIMARY KEY, json TEXT'
};

class MainDatabase {
  static final MainDatabase _mainDb = MainDatabase._internal();

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
    for (MapEntry<String, String> table in tables.entries) {
      await db.execute('CREATE TABLE IF NOT EXISTS ${table.key} (${table.value})');
    }
  }

  Future init() async {
    db = await openDatabase(await _localPath, onOpen: _onOpen);
  }
}