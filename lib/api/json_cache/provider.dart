import 'dart:async';
import 'dart:convert';

import 'package:msu_helper/api/database.dart';
import 'package:msu_helper/config/expire_time.dart';

MainDatabase database = new MainDatabase();

Future<String> retrieveCachedJson(String key, [int expireTime = ExpireTime.DEFAULT]) async {
  List<Map<String, dynamic>> rows = await database.db.query(TableName.jsonCache,
      where: 'key = ?', whereArgs: [key]);

  if (rows.length == 0) {
    return null;
  }

  Map<String, dynamic> row = rows[0];

  if (!row.containsKey('json')) {
    return null;
  }

  int retrieved = row['retrieved'] as int;

  if (!ExpireTime.isValid(retrieved, expireTime)) {
    await database.db.delete(TableName.jsonCache,
        where: 'key = ?', whereArgs: [key]);
    return null;
  }

  return row['json'];
}

Future cacheJson(String key, dynamic object) async {
  if (object is! String) {
    object = json.encode(object);
  }

  int updated = await database.db.update(TableName.jsonCache, {
    'json': object,
    'retrieved': DateTime.now().millisecondsSinceEpoch
  }, where: 'key = ?', whereArgs: [key]);

  if (updated > 0) {
    return;
  }

  await database.db.insert(TableName.jsonCache, {
    'json': object,
    'retrieved': DateTime.now().millisecondsSinceEpoch,
    'key': key
  });
}