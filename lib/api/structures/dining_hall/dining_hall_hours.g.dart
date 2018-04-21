// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dining_hall_hours.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

DiningHallHours _$DiningHallHoursFromJson(Map<String, dynamic> json) =>
    new DiningHallHours(
        closed: json['closed'] as bool,
        begin: json['begin'] as int,
        end: json['end'] as int,
        limitedMenuBegin: json['limitedMenuBegin'] as int,
        grillClosesAt: json['grillClosesAt'] as int,
        meal: json['meal'] as int,
        extra: json['extra'] as String);

abstract class _$DiningHallHoursSerializerMixin {
  bool get closed;
  int get begin;
  int get end;
  int get limitedMenuBegin;
  int get grillClosesAt;
  int get meal;
  String get extra;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'closed': closed,
        'begin': begin,
        'end': end,
        'limitedMenuBegin': limitedMenuBegin,
        'grillClosesAt': grillClosesAt,
        'meal': meal,
        'extra': extra
      };
}
