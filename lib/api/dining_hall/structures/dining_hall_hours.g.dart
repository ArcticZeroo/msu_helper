// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dining_hall_hours.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

DiningHallHours _$DiningHallHoursFromJson(Map<String, dynamic> json) =>
    new DiningHallHours(
        closed: json['closed'] as bool,
        begin: (json['begin'] as num)?.toDouble(),
        end: (json['end'] as num)?.toDouble(),
        limitedMenuBegin: (json['limitedMenuBegin'] as num)?.toDouble(),
        grillClosesAt: (json['grillClosesAt'] as num)?.toDouble(),
        extra: json['extra'] as String,
        mealOrdinal: json['meal'] as int);

abstract class _$DiningHallHoursSerializerMixin {
  bool get closed;
  double get begin;
  double get end;
  double get limitedMenuBegin;
  double get grillClosesAt;
  String get extra;
  int get mealOrdinal;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'closed': closed,
        'begin': begin,
        'end': end,
        'limitedMenuBegin': limitedMenuBegin,
        'grillClosesAt': grillClosesAt,
        'extra': extra,
        'meal': mealOrdinal
      };
}
