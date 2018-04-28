import 'dart:async';

import 'package:msu_helper/api/database.dart';
import 'package:msu_helper/api/settings/setting_data.dart';
import 'package:sqflite/sqflite.dart';

Map<String, String> settingCache = new Map();

Future<dynamic> retrieveSetting(SettingData data) async {
  if (settingCache.containsKey(data.key)) {
    return data.decode(settingCache[data.key]);
  }

  Database db = await MainDatabase.getDbInstance();

  List<Map<String, dynamic>> rows = await db.query(
      TableName.userSettings,
      columns: ['value'],
      where: 'name = ?',
      whereArgs: [data.key]
  );

  if (rows == null || rows.length == 0) {
    return null;
  }

  Map<String, dynamic> row = rows[0];
  String value = row['value'] as String;

  settingCache[data.key] = value;

  return data.decode(value);
}

Future saveSetting(SettingData data, dynamic value) async {
  Database db = await MainDatabase.getDbInstance();

  String encoded = data.encode(value);

  int rows = await db.update(
      TableName.userSettings,
      { 'value': encoded },
      where: 'name = ?',
      whereArgs: [data.key]
  );

  if (rows == 0) {
    await db.insert(TableName.userSettings, {
      'name': data.key,
      'value': encoded
    });
  }

  settingCache[data.key] = encoded;
}