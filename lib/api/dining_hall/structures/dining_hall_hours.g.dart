// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dining_hall_hours.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiningHallHours _$DiningHallHoursFromJson(Map<String, dynamic> json) {
  return new DiningHallHours(
      extra: json['extra'] as String,
      closeTimesRaw: (json['closeTimes'] as Map<String, dynamic>)
          ?.map((k, e) => new MapEntry(k, e as num)),
      openTimesRaw: (json['openTimes'] as Map<String, dynamic>)
          ?.map((k, e) => new MapEntry(k, e as num)),
      closed: json['closed'] as bool,
      begin: (json['begin'] as num)?.toDouble(),
      end: (json['end'] as num)?.toDouble(),
      limitedMenuBegin: (json['limitedMenuBegin'] as num)?.toDouble(),
      grillClosesAt: (json['grillClosesAt'] as num)?.toDouble(),
      mealOrdinal: json['meal'] as int);
}

abstract class _$DiningHallHoursSerializerMixin {
  bool get closed;
  double get begin;
  double get end;
  double get limitedMenuBegin;
  double get grillClosesAt;
  String get extra;
  int get mealOrdinal;
  Map<String, num> get closeTimesRaw;
  Map<String, num> get openTimesRaw;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'closed': closed,
        'begin': begin,
        'end': end,
        'limitedMenuBegin': limitedMenuBegin,
        'grillClosesAt': grillClosesAt,
        'extra': extra,
        'meal': mealOrdinal,
        'closeTimes': closeTimesRaw,
        'openTimes': openTimesRaw
      };
}
