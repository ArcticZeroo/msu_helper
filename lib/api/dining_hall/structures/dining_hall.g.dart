// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dining_hall.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

DiningHall _$DiningHallFromJson(Map<String, dynamic> json) => new DiningHall(
    hallName: json['hallName'] as String,
    brandName: json['brandName'] as String,
    fullName: json['fullName'] as String,
    searchName: json['searchName'] as String,
    hours: json['hours'] == null
        ? null
        : new Map<String, List<DiningHallHours>>.fromIterables(
            (json['hours'] as Map<String, dynamic>).keys,
            (json['hours'] as Map).values.map((e) => (e as List)
                ?.map((e) => e == null
                    ? null
                    : new DiningHallHours.fromJson(e as Map<String, dynamic>))
                ?.toList())));

abstract class _$DiningHallSerializerMixin {
  String get hallName;
  String get brandName;
  String get fullName;
  String get searchName;
  Map<String, List<DiningHallHours>> get hours;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'hallName': hallName,
        'brandName': brandName,
        'fullName': fullName,
        'searchName': searchName,
        'hours': hours
      };
}
