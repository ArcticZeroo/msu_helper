import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:msu_helper/api/dining_hall/Meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_menu.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/api/request.dart';
import 'package:msu_helper/api/timed_cache.dart';
import 'package:msu_helper/config/page_route.dart';

import '../database.dart';
import 'structures/dining_hall.dart';

MainDatabase database = new MainDatabase();
List<DiningHall> hallCache;
TimedCache<String, DiningHallMenu> menuCache = new TimedCache((String key) async {
  Deserialized deserialized = await deserializeFromKey(key);

  return retrieveMenuFromWeb(deserialized.diningHall, deserialized.menuDate, deserialized.meal);
}, 60*60*1000);

class Deserialized {
  final DiningHall diningHall;
  final MenuDate menuDate;
  final Meal meal;
  
  Deserialized(this.diningHall, this.menuDate, this.meal);
}

String serializeToKey(DiningHall diningHall, MenuDate time, Meal meal) {
  return [diningHall.searchName, time.getFormatted(), meal.ordinal.toString()].join('|');
}

Future<Deserialized> deserializeFromKey(String key) async {
  List<String> split = key.split('|');

  // Don't handle the orElse, since a serialized key should never
  // not be able to get deserialized
  DiningHall diningHall = (await retrieveList()).firstWhere((hall) => hall.searchName == split[0]);
  MenuDate menuDate = MenuDate.fromFormatted(split[1]);
  Meal meal = Meal.fromOrdinal(int.parse(split[2]));

  return new Deserialized(diningHall, menuDate, meal);
}

Future<List<DiningHall>> retrieveListFromDatabase() async {
  List<Map> results = await database.db.rawQuery('SELECT "json" from "${TableName.diningHalls}"');

  return results.map((r) => DiningHall.fromJson(json.decode(r['json'])));
}

Future<List<DiningHall>> retrieveListFromWeb() async {
  String url = PageRoute.getDining(PageRoute.DINING_LIST);

  List<Map<String, dynamic>> response = await makeRestRequest(url);

  return response.map((r) => DiningHall.fromJson(r));
}

Future<List<DiningHall>> retrieveListFromWebAndSave() async {
  List<DiningHall> fromDb = await retrieveListFromWeb();

  for (DiningHall diningHall in fromDb) {
    await database.db.insert(TableName.diningHalls, {
      'searchName': diningHall.searchName,
      'json': json.encode(diningHall)
    });
  }

  return fromDb;
}

Future<List<DiningHall>> retrieveList([bool respectCache = true]) async {
  if (hallCache != null && respectCache) {
    return hallCache;
  }

  List<DiningHall> fromDb = await retrieveListFromDatabase();

  if (fromDb.length > 0) {
    hallCache = fromDb;
    return fromDb;
  }

  List<DiningHall> fromWeb = await retrieveListFromWebAndSave();

  hallCache = fromWeb;
  return fromWeb;
}

Future<DiningHallMenu> retrieveMenuFromWeb(DiningHall diningHall, MenuDate date, Meal meal) async {
  String dateString = date.getFormatted();

  String url = PageRoute.getDining('${PageRoute.getDining(PageRoute.DINING_MENU)}/$dateString/${meal.ordinal}');

  Map<String, dynamic> response = await makeRestRequest(url);

  return DiningHallMenu.fromJson(response);
}

Future<DiningHallMenu> retrieveMenu(DiningHall diningHall, MenuDate date, Meal meal) {
  String key = serializeToKey(diningHall, date, meal);

  return menuCache.get(key);
}