import 'package:json_annotation/json_annotation.dart';
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

  FoodTruckStop(this.place, this.location, this.start, this.end)
      : this.startDate = DateTime.fromMillisecondsSinceEpoch(start),
        this.endDate = DateTime.fromMillisecondsSinceEpoch(end),
        this.mapsLocation = place.contains('near') ? place.split('near')[1].trim() : place,
        this.isCancelled = place.toLowerCase().contains('cancel');

  factory FoodTruckStop.fromJson(Map<String, dynamic> json) => _$FoodTruckStopFromJson(json);

  openMaps() {
    if (location == null || location.isNull) {
      UrlUtil.openMaps(mapsLocation);
      return;
    }

    UrlUtil.openMapsToCoordinates(location.x, location.y);
  }

  isNow() {
    DateTime now = DateTime.now();

    // End is not inclusive
    return (startDate.isBefore(now) || startDate.isAtSameMomentAs(now)) && endDate.isAfter(now);
  }
}

