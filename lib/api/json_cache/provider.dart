import 'dart:async';
import 'dart:convert';

import 'package:msu_helper/api/database.dart';
import 'package:msu_helper/api/timed_cache.dart';
import 'package:msu_helper/config/expire_time.dart';
import 'package:sqflite/sqflite.dart';

MainDatabase database = new MainDatabase();
Map<String, TimedCacheEntry<String>> jsonCache = new Map();

Future retrieveJsonFromDb(String key, [int expireTime = ExpireTime.THIRTY_MINUTES]) async {
  print('Retrieving stored json for $key');
  Database db = await MainDatabase.getDbInstance();

  List<Map<String, dynamic>> rows = await db.query(TableName.jsonCache,
      where: 'name = ?', whereArgs: [key]);

  if (rows.length == 0) {
    return null;
  }

  Map<String, dynamic> row = rows[0];

  if (!row.containsKey('json')) {
    return null;
  }

  int retrieved = row['retrieved'] as int;

  if (!ExpireTime.isValid(retrieved, expireTime)) {
    await db.delete(TableName.jsonCache,
        where: 'name = ?', whereArgs: [key]);
    return null;
  }

  print('$key\'s value was last retrieved at ${DateTime.fromMillisecondsSinceEpoch(retrieved)}');

  return json.decode(row['json']);
}

Future saveJsonToDb(String key, dynamic object) async {
  if (object is! String) {
    object = json.encode(object);
  }

  Database db = await MainDatabase.getDbInstance();

  int updated = await db.update(TableName.jsonCache, {
    'json': object,
    'retrieved': DateTime.now().millisecondsSinceEpoch
  }, where: 'name = ?', whereArgs: [key]);

  if (updated > 0) {
    return;
  }

  await db.insert(TableName.jsonCache, {
    'json': object,
    'retrieved': DateTime.now().millisecondsSinceEpoch,
    'name': key
  });
}