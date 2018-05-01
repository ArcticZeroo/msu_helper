import 'dart:async';

import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/time.dart';

import 'food_truck/provider.dart' as foodTruckProvider;
import 'dining_hall/provider.dart' as diningHallProvider;
import 'movie_night/provider.dart' as movieNightProvider;

Future preloadPrimaryData() async {
  DateTime startTime = DateTime.now();

  print('Preloading primary data...');
  // Preload the single-retrieval datasets,
  // but their preloading is not necessary
  // so it's OK for it to fail
  try {
    await foodTruckProvider.retrieveStops();
  } catch (e) {
    print('Could not preload food truck stops...');
    print(e);
  }

  print('Preloaded food truck stops.');

  try {
    await movieNightProvider.retrieveMovies();
  } catch (e) {
    print('Could not preload movies...');
    print(e);
  }

  print('Preloaded movie night information.');

  
  try {
    await diningHallProvider.retrieveDiningList();
  } catch (e) {
    print('Could not preload dining halls...');
    print(e);

    // This is necessary to have preloaded
    // in order to load the menus, so return
    // if secondary data shouldn't be preloaded
    throw e;
  }

  print('Preloaded dining hall information.');

  print('Primary data preload complete in ${DateTime.now().difference(startTime).inMilliseconds}ms');
}

Future preloadSecondaryData() async {
  print('Preloading secondary data...');

  List<DiningHall> diningHalls = await diningHallProvider.retrieveDiningList();

  MenuDate menuDate = MenuDate();

  // For every day in the next week,
  for (int i = 0; i < 3; i++) {
    List<Future> menuFutures = <Future>[];

    // Load every dining hall's menus on this day
    for (DiningHall diningHall in diningHalls) {
      // For every meal this dining hall serves on this day
      for (Meal meal in Meal.asList()) {
        try {
          // Add it to the list without awaiting so we can do lots of requests in a short amount of time
          menuFutures.add(diningHallProvider.retrieveMenu(diningHall, menuDate, meal));
        } catch (e) {
          // Doesn't HAVE to preload
          continue;
        }
      }
    }

    try {
      await Future.wait(menuFutures);
    } catch (e) {
      print('Could not preload menus...');
      print(e);
    }

    print('Preloaded all menus for ${menuDate.weekday}');

    menuDate.forward();
  }

  print('Preloaded all dining hall menus.');
}