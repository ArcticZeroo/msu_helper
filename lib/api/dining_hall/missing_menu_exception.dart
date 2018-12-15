import 'package:msu_helper/api/dining_hall/structures/menu_selection.dart';

class MissingMenuException implements Exception {
  final MenuSelection menuSelection;

  MissingMenuException(this.menuSelection);

  @override
  String toString() => 'Menu is missing for Hall[${menuSelection.diningHall.searchName}] Date[${menuSelection.date.getFormatted()}] ${menuSelection.meal.toString()}';
}