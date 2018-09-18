import 'dart:async';

import 'package:msu_helper/api/database.dart';
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/api/json_cache/provider.dart' as jsonCache;
import 'package:msu_helper/api/request.dart';
import 'package:msu_helper/api/timed_cache.dart';
import 'package:msu_helper/config/expire_time.dart';
import 'package:msu_helper/config/identifier.dart';
import 'package:msu_helper/config/page_route_config.dart';
import 'package:synchronized/synchronized.dart';

TimedCacheEntry<List<FoodTruckStop>> truckStopCache;
Lock foodTruckLock = new Lock();

Future<List<FoodTruckStop>> retrieveStopsFromWeb() async {
  String url = PageRouteConfig.getFoodTruck(PageRouteConfig.LIST);

  List<dynamic> response = await makeRestRequest(url);

  return response.map((r) => FoodTruckStop.fromJson(r as Map<String, dynamic>)).toList();
}

Future<List<FoodTruckStop>> retrieveStopsFromWebAndSave() async {
  List<FoodTruckStop> fromWeb = await retrieveStopsFromWeb();

  if (fromWeb != null && fromWeb.length != 0) {
    setCached(fromWeb);

    await jsonCache.saveJsonToDb(Identifier.foodTruck, fromWeb);

    return fromWeb;
  }

  return null;
}

Future<List<FoodTruckStop>> retrieveStopsFromDb() async {
  List<dynamic> stopJsonMap = await jsonCache.retrieveJsonFromDb(Identifier.foodTruck);

  if (stopJsonMap == null) {
    return null;
  }

  return stopJsonMap.map((j) => FoodTruckStop.fromJson(j as Map<String, dynamic>)).toList();
}

void setCached(List<FoodTruckStop> stops) {
  truckStopCache = new TimedCacheEntry(stops, expireTime: ExpireTime.THIRTY_MINUTES);
}

List<FoodTruckStop> getCached() {
  if (truckStopCache != null && truckStopCache.isValid()) {
    return List.from(truckStopCache.value);
  }

  return null;
}


List<FoodTruckStop> setAndGetCache(List<FoodTruckStop> stops) {
  setCached(stops);
  return getCached();
}

Future<List<FoodTruckStop>> retrieveStops() async {
  List<FoodTruckStop> stops = await foodTruckLock.synchronized(() async {
    List<FoodTruckStop> cached = getCached();

    if (cached != null) {
      return cached;
    }

    List<FoodTruckStop> fromDb = await retrieveStopsFromDb();

    if (fromDb != null && fromDb.length != 0) {
      return setAndGetCache(fromDb);
    }

    await retrieveStopsFromWebAndSave();
    return getCached();
  });

  return stops;
}