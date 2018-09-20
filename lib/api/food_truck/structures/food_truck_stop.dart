import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/provider.dart' as diningHallProvider;
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/food_truck/enum/stop_state.dart';
import 'package:msu_helper/api/point.dart';
import 'package:msu_helper/util/UrlUtil.dart';

part './food_truck_stop.g.dart';

@JsonSerializable()
class FoodTruckStop extends Object with _$FoodTruckStopSerializerMixin {
  final String place;
  final String mapsLocation;
  final Point location;
  final bool isCancelled;

  final DateTime startDate;
  final DateTime endDate;

  final int start;
  final int end;

  String get shortName => mapsLocation.toLowerCase().startsWith('the') ? mapsLocation : 'the $mapsLocation';

  FoodTruckStop({this.place, this.location, this.start, this.end, this.isCancelled})
      : this.startDate = DateTime.fromMillisecondsSinceEpoch(start),
        this.endDate = DateTime.fromMillisecondsSinceEpoch(end),
        this.mapsLocation = place.contains('near') ? place.split('near')[1].trim() : place;

  factory FoodTruckStop.fromJson(Map<String, dynamic> json) => _$FoodTruckStopFromJson(json);

  Future openMaps() async {
    if (!(location ?? new Point()).isNull) {
      UrlUtil.openMapsToCoordinates(location.x, location.y);
      return;
    }

    List<DiningHall> diningHalls = await diningHallProvider.retrieveDiningList();

    DiningHall mentionedHall = diningHalls.firstWhere(
            (hall) => this.mapsLocation.toLowerCase().contains(hall.searchName),
        orElse: () => null
    );

    if (mentionedHall != null) {
      mentionedHall.openInMaps();
      return;
    }

    UrlUtil.openMapsToLocation(mapsLocation);
  }

  bool get isNow {
    DateTime now = DateTime.now();

    // End is not inclusive
    return (startDate.isBefore(now) || startDate.isAtSameMomentAs(now)) && endDate.isAfter(now);
  }

  bool get isToday {
    DateTime now = DateTime.now();

    return now.day == startDate.day && now.month == startDate.month && now.year == startDate.year;
  }
  
  FoodTruckStopState get currentState {
    if (isCancelled) {
      return FoodTruckStopState.cancelled;
    } else {
      if (isToday) {
        DateTime now = DateTime.now();

        // Check if this stop has passed first so we can add the maps button in else
        if (endDate.isBefore(now) || endDate.isAtSameMomentAs(now)) {
          return FoodTruckStopState.passed;
        } else {
          // Check if start <= now < end
          if (isNow) {
            return FoodTruckStopState.active;
            // Otherwise, since we know now is not after the end, it must be coming later than now
          } else {
            return FoodTruckStopState.arriving_soon;
          }
        }
      }
    }
    // Stop has not passed, been cancelled, and is not today
    return FoodTruckStopState.upcoming;
  }

  @override
  String toString() {
    return "FoodTruckStop[$shortName](Cancelled=$isCancelled)";
  }
}

