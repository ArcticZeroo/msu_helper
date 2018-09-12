import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_hours.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_menu.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_venue.dart';
import 'package:msu_helper/api/dining_hall/structures/food_item.dart';
import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/UrlUtil.dart';

import '../provider.dart' as diningHallProvider;

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

  List<DiningHallHours> getHoursForDay(MenuDate date) {
    return hours[DateUtil.getWeekday(date.time).toLowerCase()];
  }

  DiningHallHours getHoursForMeal(MenuDate date, Meal meal) {
    return getHoursForDay(date)[meal.ordinal];
  }

  void openInMaps() {
    UrlUtil.openMapsToLocation(this.hallName);
  }

  @override
  String toString() {
    return "DiningHall[$searchName]";
  }
}