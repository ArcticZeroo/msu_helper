import 'dart:async';

import 'package:msu_helper/api/database.dart';
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/api/json_cache/provider.dart' as jsonCache;
import 'package:msu_helper/api/request.dart';
import 'package:msu_helper/api/timed_cache.dart';
import 'package:msu_helper/config/expire_time.dart';
import 'package:msu_helper/config/identifier.dart';
import 'package:msu_helper/config/page_route.dart';

MainDatabase mainDb = new MainDatabase();
TimedCacheEntry<List<FoodTruckStop>> truckStopCache;

Future<List<FoodTruckStop>> retrieveStopsFromWeb() async {
  String url = PageRoute.getFoodTruck(PageRoute.LIST);

  List<Map<String, dynamic>> response = await makeRestRequest(url);

  return response.map((r) => FoodTruckStop.fromJson(r));
}

Future<List<FoodTruckStop>> retrieveStopsFromDb() async {
  List<Map> stopJsonMap = await jsonCache.retrieveJsonFromDb(Identifier.foodTruck);

  if (stopJsonMap == null) {
    return null;
  }

  return stopJsonMap.map((j) => FoodTruckStop.fromJson(j));
}

void setCached(List<FoodTruckStop> stops) {
  truckStopCache = new TimedCacheEntry(stops, expireTime: ExpireTime.THIRTY_MINUTES);
}

Future<List<FoodTruckStop>> retrieveStops() async {
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
    return fromWeb;
  }

  return null;
}