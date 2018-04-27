// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_truck_stop.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

FoodTruckStop _$FoodTruckStopFromJson(Map<String, dynamic> json) =>
    new FoodTruckStop(
        json['place'] as String,
        json['location'] == null
            ? null
            : new Point.fromJson(json['location'] as Map<String, dynamic>),
        json['start'] as int,
        json['end'] as int);

abstract class _$FoodTruckStopSerializerMixin {
  String get place;
  Point get location;
  int get start;
  int get end;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'place': place,
        'location': location,
        'start': start,
        'end': end
      };
}
