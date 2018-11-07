// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_truck_stop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodTruckStop _$FoodTruckStopFromJson(Map<String, dynamic> json) {
  return new FoodTruckStop(json['place'] as String, json['start'] as int,
      json['end'] as int, json['isCancelled'] as bool);
}

abstract class _$FoodTruckStopSerializerMixin {
  String get place;
  bool get isCancelled;
  int get start;
  int get end;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'place': place,
        'isCancelled': isCancelled,
        'start': start,
        'end': end
      };
}
