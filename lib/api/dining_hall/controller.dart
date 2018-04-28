import 'dart:async';

import 'package:msu_helper/api/dining_hall/provider.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/settings/provider.dart';
import 'package:msu_helper/config/settings.dart';

Future<DiningHall> fromSearchName(String searchName) async {
  List<DiningHall> diningHalls = await retrieveList();

  if (diningHalls == null || diningHalls.length == 0) {
    return null;
  }

  return diningHalls.firstWhere(
      (diningHall) => diningHall.searchName == searchName,
      orElse: () => null
  );
}

Future<DiningHall> retrieveFavoriteHall() async {
  String searchName = await retrieveSettingFromDb(SettingsConfig.favoriteDiningHall);

  if (searchName == null) {
    return null;
  }

  return fromSearchName(searchName);
}