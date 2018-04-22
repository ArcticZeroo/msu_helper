import 'dart:async';

import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/api/request.dart';
import 'package:msu_helper/config/page_route.dart';

List<FoodTruckStop> stopCache;

Future<List<FoodTruckStop>> retrieveListFromWeb() async {
  String url = PageRoute.getFoodTruck(PageRoute.LIST);

  List<Map<String, dynamic>> response = await makeRestRequest(url);

  return response.map((r) => FoodTruckStop.fromJson(r));
}