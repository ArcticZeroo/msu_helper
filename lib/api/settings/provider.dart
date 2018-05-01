import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/database.dart';
import 'package:msu_helper/api/settings/setting_data.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:sqflite/sqflite.dart';

Map<String, SettingsNotifier> settingCache = new Map();

void main() {
  for (SettingData data in SettingsConfig.allSettings) {
    addNotifierToCacheMap(data);
  }
}

typedef void SettingsNotifyCallback(String last);
class SettingsNotifier extends ValueNotifier<String> {
  String last;

  SettingsNotifier(value) : super(value);

  setValue(String newValue) {
    last = value;
    value = newValue;
  }
}

void addNotifierToCacheMap(SettingData data) {
  settingCache[data.key] = new SettingsNotifier(null);
}

void addToCache(SettingData data, dynamic value) {
  if (!settingCache.containsKey(data.key)) {
    addNotifierToCacheMap(data);
  }

  settingCache[data.key].setValue(value);
}

Future<dynamic> retrieveSetting(SettingData data) async {
  if (settingCache.containsKey(data.key) && settingCache[data.key].value != null) {
    return data.decode(settingCache[data.key].value);
  }

  Database db = await MainDatabase.getDbInstance();

  List<Map<String, dynamic>> rows = await db.query(
      TableName.userSettings,
      columns: ['value'],
      where: 'name = ?',
      whereArgs: [data.key]
  );

  if (rows == null || rows.length == 0) {
    if (data.defaultValue == null) {
      return null;
    }

    await saveSetting(data, data.defaultValue);

    return data.defaultValue;
  }

  Map<String, dynamic> row = rows[0];
  String value = row['value'] as String;

  settingCache[data.key].setValue(value);

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

  settingCache[data.key].setValue(encoded);
}

Future loadAllSettings() async {
  Database db = await MainDatabase.getDbInstance();

  List<Map<String, dynamic>> rows = await db.rawQuery('SELECT * FROM ${TableName.userSettings}');

  if (rows == null || rows.length == 0) {
    return;
  }

  Map<String, SettingData> settingConfigMap = {};

  for (SettingData data in SettingsConfig.allSettings) {
    settingConfigMap[data.key] = data;
  }

  for (Map<String, dynamic> row in rows) {
    String name = row['name'];
    String value = row['value'];

    if (!settingConfigMap.containsKey(name)) {
      continue;
    }

    SettingData data = settingConfigMap[name];

    addToCache(data, data.decode(value));

    settingConfigMap.remove(name);
  }

  for (SettingData data in settingConfigMap.values) {
    addToCache(data, data.defaultValue);
  }
}

void addSettingListener(SettingData data, SettingsNotifyCallback listener) {
  if (!settingCache.containsKey(data.key)) {
    addNotifierToCacheMap(data);
  }

  settingCache[data.key].addListener(() {
    listener(settingCache[data.key].last);
  });
}