import 'dart:async';

import 'package:msu_helper/api/database.dart';
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/api/json_cache/provider.dart' as jsonCache;
import 'package:msu_helper/api/request.dart';
import 'package:msu_helper/api/timed_cache.dart';
import 'package:msu_helper/config/expire_time.dart';
import 'package:msu_helper/config/identifier.dart';
import 'package:msu_helper/config/page_route.dart';

TimedCacheEntry<List<FoodTruckStop>> truckStopCache;

Future<List<FoodTruckStop>> retrieveStopsFromWeb() async {
  print('Retrieving stops from web...');
  String url = PageRoute.getFoodTruck(PageRoute.LIST);

  List<dynamic> response = await makeRestRequest(url);

  return response.map((r) => FoodTruckStop.fromJson(r as Map<String, dynamic>)).toList();
}

Future<List<FoodTruckStop>> retrieveStopsFromDb() async {
  print('Retrieving stops from db...');
  List<dynamic> stopJsonMap = await jsonCache.retrieveJsonFromDb(Identifier.foodTruck);

  if (stopJsonMap == null) {
    return null;
  }

  stopJsonMap.forEach((json) => print(json as Map<String, dynamic>));

  return stopJsonMap.map((j) => FoodTruckStop.fromJson(j as Map<String, dynamic>)).toList();
}

void setCached(List<FoodTruckStop> stops) {
  print('Adding stops to cache...');
  truckStopCache = new TimedCacheEntry(stops, expireTime: ExpireTime.THIRTY_MINUTES);
}

Future<List<FoodTruckStop>> retrieveStops() async {
  print('Retrieving food truck stops...');

  if (truckStopCache != null && truckStopCache.isValid()) {
    return truckStopCache.value;
  }

  List<FoodTruckStop> fromDb = await retrieveStopsFromDb();

  if (fromDb != null && fromDb.length != 0) {
    setCached(fromDb);
    return fromDb;
  }

  List<FoodTruckStop> fromWeb = await retrieveStopsFromWeb();

  if (fromWeb != null && fromWeb.length != 0) {
    setCached(fromWeb);

    print('Saving stops to db...');
    await jsonCache.saveJsonToDb(Identifier.foodTruck, fromWeb);

    return fromWeb;
  }

  return null;
}