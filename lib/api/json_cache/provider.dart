import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:msu_helper/api/database.dart';
import 'package:msu_helper/api/request.dart';
import 'package:msu_helper/api/timed_cache.dart';
import 'package:msu_helper/config/expire_time.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

MainDatabase database = new MainDatabase();
Map<String, TimedCacheEntry<String>> jsonCache = new Map();
Lock jsonLock = new Lock();

Future retrieveJsonFromDb(String key, [num expireTime = ExpireTime.THIRTY_MINUTES]) async {
    return jsonLock.synchronized(() async {
        Database db = await MainDatabase.getDbInstance();

        List<Map<String, dynamic>> rows = await db.query(TableName.jsonCache,
            where: 'name = ?', whereArgs: [key]);

        if (rows.isEmpty) {
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

        return json.decode(row['json']);
    });
}

Future saveJsonToDb(String key, dynamic object) async {
    if (object == null) {
        throw new Exception('Object to save to $key is null');
    }

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

Future retrieveJsonFromWebAndSave(String key, String url, [Duration timeout = const Duration(milliseconds: 10*1000)]) async {
    dynamic data = await makeRestRequest(url).timeout(timeout);

    await saveJsonToDb(key, data);

    return data;
}

Future retrieveJson({
    @required String key,
    @required String urlIfNeeded,
    Duration timeout = const Duration(seconds: 10),
    num expireTime = ExpireTime.THIRTY_MINUTES
}) async {
    dynamic data = null;
    try {
        data = await retrieveJsonFromDb(key, expireTime);
    } catch (e) {
        print('Could not get json from db... $e');
    }

    if (data != null) {
        if (data is! String) {
            return data;
        }

        return json.decode(data);
    }

    return retrieveJsonFromWebAndSave(key, urlIfNeeded, timeout);
}

