import 'dart:async';

import 'package:msu_helper/api/dining_hall/provider.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/settings/provider.dart';
import 'package:msu_helper/config/settings_config.dart';

Future<DiningHall> fromSearchName(String searchName) async {
  List<DiningHall> diningHalls = await retrieveDiningList();

  if (diningHalls == null || diningHalls.isEmpty) {
    return null;
  }

  return diningHalls.firstWhere(
      (diningHall) => diningHall.searchName == searchName,
      orElse: () => null
  );
}

Future<DiningHall> retrieveFavoriteHall() async {
  String searchName = await retrieveSetting(SettingsConfig.favoriteDiningHall);

  if (searchName == null) {
    return null;
  }

  return fromSearchName(searchName);
}