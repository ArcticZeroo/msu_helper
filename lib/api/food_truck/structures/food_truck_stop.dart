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

  String get shortName => mapsLocation.toLowerCase().startsWith('the') ? mapsLocation : 'the $mapsLocation';

  FoodTruckStop({this.place, this.location, this.start, this.end, this.isCancelled})
      : this.startDate = DateTime.fromMillisecondsSinceEpoch(start),
        this.endDate = DateTime.fromMillisecondsSinceEpoch(end),
        this.mapsLocation = place.contains('near') ? place.split('near')[1].trim() : place;

  factory FoodTruckStop.fromJson(Map<String, dynamic> json) => _$FoodTruckStopFromJson(json);

  void openMaps() {
    if (location == null || location.isNull) {
      UrlUtil.openMapsToLocation(mapsLocation);
      return;
    }

    UrlUtil.openMapsToCoordinates(location.x, location.y);
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

  @override
  String toString() {
    return "FoodTruckStop[$shortName](Cancelled=$isCancelled)";
  }
}

