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
import 'package:synchronized/synchronized.dart';

import '../../config/identifier.dart';
import '../json_cache/provider.dart' as jsonProvider;
import 'structures/dining_hall.dart';

List<DiningHall> hallCache;
Lock diningHallListLock = new Lock();
final int expireTime = ExpireTime.THIRTY_MINUTES * 2;

TimedCache<String, DiningHallMenu> menuCache = new TimedCache((String key) async {
  MenuMetadata deserialized = await deserializeFromKey(key);

  TimedCacheEntry<DiningHallMenu> fromDb = await retrieveMenuFromDatabase(deserialized.diningHall, deserialized.menuDate, deserialized.meal);

  if (fromDb != null && fromDb.isValid()) {
    // If the cached menu entry says it's closed,
    // only consider it invalid if the dining hall
    // doesn't seem to suggest it should be closed
    // (and therefore requires a refresh)
    if (fromDb.value.closed && !deserialized.diningHall.getHoursForMeal(deserialized.menuDate, deserialized.meal).closed) {

    } else {
      return fromDb;
    }
  }

  DiningHallMenu menu = await retrieveMenuFromWeb(deserialized.diningHall, deserialized.menuDate, deserialized.meal);

  await saveMenuToDb(deserialized.diningHall, deserialized.menuDate, deserialized.meal, menu);

  return new TimedCacheEntry(menu, expireTime: expireTime);
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
  DiningHall diningHall = (await retrieveDiningList()).firstWhere((hall) => hall.searchName == split[0]);
  MenuDate menuDate = MenuDate.fromFormatted(split[1]);
  Meal meal = Meal.fromOrdinal(int.parse(split[2]));

  return new MenuMetadata(diningHall, menuDate, meal);
}

List<DiningHall> diningListFromJson(List<dynamic> parsedJson) {
  return parsedJson.map((r) => DiningHall.fromJson(r as Map<String, dynamic>)).toList();
}

Future<List<DiningHall>> retrieveDiningListFromDatabase() async {
  List<dynamic> storedJson = await jsonProvider.retrieveJsonFromDb(Identifier.diningHall, double.infinity);

  if (storedJson == null) {
    return null;
  }

  return diningListFromJson(storedJson);
}

Future<List<DiningHall>> retrieveDiningListFromWeb() async {
  String url = PageRoute.getDining(PageRoute.LIST);

  List<dynamic> response = await makeRestRequest(url);

  return diningListFromJson(response);
}

Future<List<DiningHall>> retrieveDiningListFromWebAndSave() async {
  List<DiningHall> fromWeb = await retrieveDiningListFromWeb();

  jsonProvider.saveJsonToDb(Identifier.diningHall, json.encode(fromWeb));

  return fromWeb;
}

Future<List<DiningHall>> retrieveDiningList() async {
  return diningHallListLock.synchronized(() async {
    if (hallCache != null && hallCache.length != 0) {
      return hallCache;
    }

    List<DiningHall> fromDb = await retrieveDiningListFromDatabase();

    if (fromDb != null && fromDb.length > 0) {
      hallCache = fromDb;
      return fromDb;
    }

    List<DiningHall> fromWeb = await retrieveDiningListFromWebAndSave();

    if (fromWeb != null) {
      hallCache = fromWeb;
      return fromWeb;
    }

    return null;
  });
}

DiningHallMenu _diningHallMenuFromJson(Map<String, dynamic> json, DiningHall diningHall) {
  return DiningHallMenu.fromJson(json).copyWith(diningHall: diningHall);
}

Future<DiningHallMenu> retrieveMenuFromWeb(DiningHall diningHall, MenuDate date, Meal meal) async {
  String dateString = date.getFormatted();

  String url = PageRoute.join([PageRoute.getDining(PageRoute.MENU), diningHall.searchName, dateString, meal.ordinal.toString()]);

  Map<String, dynamic> response = (await makeRestRequest(url)) as Map<String, dynamic>;

  return _diningHallMenuFromJson(response, diningHall);
}

/*Future<Map<DiningHall, List<DiningHallMenu>>> retrieveMenusForDayFromDb(MenuDate date) async {
  Database db = await MainDatabase.getDbInstance();

  var rows = await db.query(TableName.diningHallMenu,
      columns: ['searchName', 'date', 'meal', 'json'],
      where: 'date = ?',
      whereArgs: [date.getFormatted()]
  );

  Map<DiningHall, List<Meal>> containedMeals = {};

  for (var row in rows) {

  }

  Map<DiningHall, int> expectedMenusPerHall = {};

  List<DiningHall> halls = await retrieveDiningList();
  List<Meal> meals = Meal.asList();

  for (var meal in meals) {
    for (var hall in halls) {
      var hours = hall.getHoursForMeal(date, meal);

      if (hours != null || hours.closed) {
        continue;
      }

      expectedMenusPerHall.update(hall, (v) => v + 1, ifAbsent: () => 1);
    }
  }
}*/

//TODO: Don't retrieve these menus unless necessary. It may be pertinent to switch from storing a single menu
// to all the menus for a day or something
Future<Map<DiningHall, List<DiningHallMenu>>> retrieveMenusForDayFromWeb(MenuDate date) async {
  String dateString = date.getFormatted();

  String url = PageRoute.join([PageRoute.getDining(PageRoute.MENU), 'all', dateString]);

  Map<String, dynamic> response = (await makeRestRequest(url)) as Map<String, dynamic>;

  Map<String, DiningHall> searchNameToHall = {};
  List<DiningHall> diningHalls = await retrieveDiningList();

  for (DiningHall diningHall in diningHalls) {
    searchNameToHall[diningHall.searchName] = diningHall;
  }

  Map<DiningHall, List<DiningHallMenu>> menusForDay = {};

  for (String hallSearchName in response.keys) {
    DiningHall diningHall = searchNameToHall[hallSearchName];

    List<dynamic> jsonHallMenus = response[hallSearchName] as List<dynamic>;
    List<DiningHallMenu> hallMenus = [];

    for (var json in jsonHallMenus) {
      Map<String, dynamic> jsonMenu = json as Map<String, dynamic>;

      hallMenus.add(_diningHallMenuFromJson(
          jsonMenu,
          diningHall
      ));
    }

    menusForDay[diningHall] = hallMenus;
  }

  return menusForDay;
}

Future saveManyMenusToDbAndCache(Map<DiningHall, List<DiningHallMenu>> diningHallToMenus, MenuDate date) async {
  Database db = await MainDatabase.getDbInstance();

  String dateString = date.getFormatted();
  String where = "searchName in (?) AND date = ?";

  // Clear out all old entries so we don't have to
  // deal with an over complex insert or update type deal
  await db.delete(
      TableName.diningHallMenu,
      where: where,
      whereArgs: [
        diningHallToMenus.keys.map((diningHall) => diningHall.searchName).join(','),
        dateString
      ]
  );

  int retrieved = DateTime.now().millisecondsSinceEpoch;

  List<String> values = [];

  for (var entry in diningHallToMenus.entries) {
    DiningHall diningHall = entry.key;
    String searchName = entry.key.searchName;
    int menuCount = entry.value.length;
    for (int i = 0; i < menuCount; i++) {
      DiningHallMenu menu = entry.value[i];
      String menuJson = json.encode(menu);

      values.add('($searchName, $dateString, $i, $retrieved, $menuJson)');
      menuCache.put(serializeToKey(diningHall, date, Meal.fromOrdinal(i)), menu, added: retrieved);
    }
  }

  await db.rawInsert("INSERT INTO ${TableName.diningHallMenu}(searchName, date, meal, retrieved, json) VALUES ${values.join(',')}");
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
  DiningHallMenu diningHallMenu = DiningHallMenu
      .fromJson(json.decode(result['json']) as Map<String, dynamic>)
      .copyWith(diningHall: diningHall);

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
  return new TimedCacheEntry<DiningHallMenu>(
      diningHallMenu,
      added: retrieved,
      expireTime: expireTime
  );
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

bool isMenuCached({ DiningHall diningHall, MenuDate date, Meal meal }) {
  return menuCache.hasValid(serializeToKey(diningHall, date, meal));
}