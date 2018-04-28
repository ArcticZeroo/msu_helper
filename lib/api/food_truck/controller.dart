import 'dart:async';

import 'package:msu_helper/api/food_truck/provider.dart';
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';

Future<FoodTruckStop> retrieveMostRelevant() async {
  List<FoodTruckStop> stops = await retrieveStops();

  if (stops == null || stops.length == 0) {
    return null;
  }

  DateTime now = DateTime.now();

  // Sort in ascending order of start time
  stops.sort((a, b) => a.startDate.millisecondsSinceEpoch - b.startDate.millisecondsSinceEpoch);

  // If no stops have passed, return the next one to start
  if (now.isBefore(stops[0].startDate)) {
    return stops[0];
  }

  // Remove all stops where the end has already passed
  stops.removeWhere((stop) => stop.endDate.isBefore(now) || stop.endDate.isAtSameMomentAs(now));

  if (stops.length == 0) {
    return null;
  }

  FoodTruckStop stopNow = stops.firstWhere((stop) => stop.isNow(),
      orElse: () => null);

  if (stopNow != null) {
    return stopNow;
  }

  return stops.firstWhere((stop) => stop.startDate.isAfter(now) || stop.startDate.isAtSameMomentAs(now),
      orElse: () => null);
}