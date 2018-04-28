import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
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
  }) {
    for (List<DiningHallHours> dayHours in hours.values) {
      while (dayHours.length < Meal.count) {
        dayHours.add(new DiningHallHours(
            closed: true,
            mealOrdinal: dayHours.length
        ));
      }
    }
  }

  final String hallName;
  final String brandName;
  final String fullName;
  final String searchName;
  final Map<String, List<DiningHallHours>> hours;

  factory DiningHall.fromJson(Map<String, dynamic> json) => _$DiningHallFromJson(json);

  @override
  String toString() {
    return "DiningHall[$searchName]";
  }
}