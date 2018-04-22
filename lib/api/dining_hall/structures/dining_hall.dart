import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';

part './dining_hall.g.dart';

@JsonSerializable()
class DiningHall extends Object with _$DiningHallSerializerMixin {
  DiningHall({
    this.hallName,
    this.brandName,
    this.fullName,
    this.searchName,
    this.hours
  });

  final String hallName;
  final String brandName;
  final String fullName;
  final String searchName;
  final Map<String, List<DiningHallHours>> hours;

  factory DiningHall.fromJson(Map<String, dynamic> json) => _$DiningHallFromJson(json);
}