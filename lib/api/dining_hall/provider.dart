import 'dart:async';
import 'dart:convert';

import 'package:msu_helper/api/database.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_menu.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/api/request.dart';
import 'package:msu_helper/api/timed_cache.dart';
import 'package:msu_helper/config/expire_time.dart';
import 'package:msu_helper/config/page_route.dart';
import 'package:sqflite/sqflite.dart';

import 'structures/dining_hall.dart';

List<DiningHall> hallCache;
TimedCache<String, DiningHallMenu> menuCache = new TimedCache((String key) async {
  MenuMetadata deserialized = await deserializeFromKey(key);

  TimedCacheEntry<DiningHallMenu> fromDb = await retrieveMenuFromDatabase(deserialized.diningHall, deserialized.menuDate, deserialized.meal);

  if (fromDb != null) {
    return fromDb;
  }

  DiningHallMenu menu = await retrieveMenuFromWeb(deserialized.diningHall, deserialized.menuDate, deserialized.meal);

  await saveMenuToDb(deserialized.diningHall, deserialized.menuDate, deserialized.meal, menu);

  return menu;
}, 60*60*1000);

class MenuMetadata {
  final DiningHall diningHall;
  final MenuDate menuDate;
  final Meal meal;
  
  MenuMetadata(this.diningHall, this.menuDate, this.meal);
}

String serializeToKey(DiningHall diningHall, MenuDate time, Meal meal) {
  return [diningHall.searchName, time.getFormatted(), meal.ordinal.toString()].join('|');
}

Future<MenuMetadata> deserializeFromKey(String key) async {
  List<String> split = key.split('|');

  // Don't handle the orElse, since a serialized key should never
  // not be able to get deserialized
  DiningHall diningHall = (await retrieveList()).firstWhere((hall) => hall.searchName == split[0]);
  MenuDate menuDate = MenuDate.fromFormatted(split[1]);
  Meal meal = Meal.fromOrdinal(int.parse(split[2]));

  return new MenuMetadata(diningHall, menuDate, meal);
}

Future<List<DiningHall>> retrieveListFromDatabase() async {
  Database db = await MainDatabase.getDbInstance();

  List<dynamic> results = await db.rawQuery('SELECT "json" from "${TableName.diningHalls}"');

  return results.map((r) => DiningHall.fromJson(json.decode(r['json']) as Map<String, dynamic>)).toList();
}

Future<List<DiningHall>> retrieveListFromWeb() async {
  String url = PageRoute.getDining(PageRoute.LIST);

  List<dynamic> response = await makeRestRequest(url);

  return response.map((r) => DiningHall.fromJson(r as Map<String, dynamic>)).toList();
}

Future<List<DiningHall>> retrieveListFromWebAndSave() async {
  List<DiningHall> fromWeb = await retrieveListFromWeb();

  Database db = await MainDatabase.getDbInstance();

  for (DiningHall diningHall in fromWeb) {
    await db.insert(TableName.diningHalls, {
      'searchName': diningHall.searchName,
      'json': json.encode(diningHall)
    });
  }

  return fromWeb;
}

Future<List<DiningHall>> retrieveList() async {
  print('Getting dining hall list');

  if (hallCache != null && hallCache.length != 0) {
    print('Returning a cached value');
    return hallCache;
  }

  List<DiningHall> fromDb = await retrieveListFromDatabase();

  if (fromDb.length > 0) {
    print('Returning a value from db');
    hallCache = fromDb;
    return fromDb;
  }

  List<DiningHall> fromWeb = await retrieveListFromWebAndSave();

  if (fromWeb != null) {
    print('Returning a web value');
    hallCache = fromWeb;
    return fromWeb;
  }

  print('None found');
  return null;
}

Future<DiningHallMenu> retrieveMenuFromWeb(DiningHall diningHall, MenuDate date, Meal meal) async {
  String dateString = date.getFormatted();

  String url = PageRoute.join([PageRoute.getDining(PageRoute.MENU), dateString, meal.ordinal.toString()]);

  Map<String, dynamic> response = (await makeRestRequest(url)) as Map<String, dynamic>;

  return DiningHallMenu.fromJson(response);
}

Future<TimedCacheEntry<DiningHallMenu>> retrieveMenuFromDatabase(DiningHall diningHall, MenuDate date, Meal meal) async {
  Database db = await MainDatabase.getDbInstance();

  String where = "searchName = ? AND date = ? AND meal = ?";
  List whereArgs = [diningHall.searchName, date.getFormatted(), meal.ordinal.toString()];

  List<Map<String, dynamic>> results = await db.query(TableName.diningHallMenu,
      columns: ['json', 'retrieved'],
      where: where,
      whereArgs: whereArgs);

  if (results.length == 0) {
    return null;
  }

  Map<String, dynamic> result = results[0];

  int retrieved = result['retrieved'] as int;
  DiningHallMenu diningHallMenu = DiningHallMenu.fromJson(json.decode(result['json']) as Map<String, dynamic>);

  int elapsedMs = DateTime.now().millisecondsSinceEpoch - retrieved;
  if (diningHallMenu.closed) {
    // This is an invalid entry if it's been half the expiry and
    // the hall is closed
    if (elapsedMs >= ExpireTime.DAY / 2) {
      // Remove the row if it's invalid
      await db.delete(TableName.diningHallMenu,
          where: where,
          whereArgs: whereArgs);
      return null;
    }
    // This is an invalid entry if it's been too long since it was retrieved
  } else if (elapsedMs >= ExpireTime.DAY) {
    // Remove the row if it's invalid
    await db.delete(TableName.diningHallMenu,
        where: where,
        whereArgs: whereArgs);
    return null;
  }

  // The entry is valid
  return new TimedCacheEntry<DiningHallMenu>(diningHallMenu, added: retrieved);
}

Future saveMenuToDb(DiningHall diningHall, MenuDate date, Meal meal, DiningHallMenu menu) async {
  Database db = await MainDatabase.getDbInstance();

  String where = "searchName = ? AND date = ? AND meal = ?";
  List whereArgs = [diningHall.searchName, date.getFormatted(), meal.ordinal.toString()];

  String jsonString = json.encode(menu);
  int retrieved = DateTime.now().millisecondsSinceEpoch;

  int rows = await db.update(TableName.diningHallMenu, {
    'json': jsonString,
    'retrieved': retrieved
  }, where: where, whereArgs: whereArgs);

  if (rows == 0) {
    await db.insert(TableName.diningHallMenu, {
      'json': jsonString,
      'retrieved': retrieved,
      'searchName': diningHall.searchName,
      'meal': meal.ordinal,
      'date': date.getFormatted()
    });
  }
}

Future removeOldMenus() async {
  Database db = await MainDatabase.getDbInstance();

  return db.delete(TableName.diningHallMenu,
      where: 'retrieved < ?',
      whereArgs: [ExpireTime.getLastTime(ExpireTime.DAY)]);
}

Future<DiningHallMenu> retrieveMenu(DiningHall diningHall, MenuDate date, Meal meal) async {
  String key = serializeToKey(diningHall, date, meal);

  return menuCache.get(key);
}