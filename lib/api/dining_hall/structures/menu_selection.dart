import 'package:meta/meta.dart';
import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/time.dart';

class MenuSelection {
  final DiningHall diningHall;
  final MenuDate date;
  final Meal meal;

  MenuSelection({
    @required
    this.diningHall,
    @required
    this.date,
    @required
    this.meal
  });

  MenuSelection copyWith({
    DiningHall diningHall,
    MenuDate date,
    Meal meal
  }) {
    return MenuSelection(
      diningHall: diningHall ?? this.diningHall,
      date: date ?? this.date,
      meal: meal ?? this.meal
    );
  }
}