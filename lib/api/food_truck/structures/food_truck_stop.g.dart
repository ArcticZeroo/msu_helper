// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_truck_stop.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

FoodTruckStop _$FoodTruckStopFromJson(Map<String, dynamic> json) =>
    new FoodTruckStop(
        place: json['place'] as String,
        location: json['location'] == null
            ? null
            : new Point.fromJson(json['location'] as Map<String, dynamic>),
        start: json['start'] as int,
        end: json['end'] as int,
        isCancelled: json['isCancelled'] as bool);

abstract class _$FoodTruckStopSerializerMixin {
  String get place;
  Point get location;
  bool get isCancelled;
  int get start;
  int get end;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'place': place,
        'location': location,
        'isCancelled': isCancelled,
        'start': start,
        'end': end
      };
}
