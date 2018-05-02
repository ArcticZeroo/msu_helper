import 'dart:async';

import 'package:msu_helper/api/dining_hall/meal.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/time.dart';

import 'settings/provider.dart' as settingsProvider;
import 'food_truck/provider.dart' as foodTruckProvider;
import 'dining_hall/provider.dart' as diningHallProvider;
import 'movie_night/provider.dart' as movieNightProvider;

Future preload(Future future, String name) {
  return future.then((_) => print('Preloaded $name.')).catchError((e) {
    print('Could not preload $name...');

    if (e is Error) {
      print(e.stackTrace);
    }
  });
}

Future preloadPrimaryData() async {
  DateTime startTime = DateTime.now();

  print('Preloading primary data...');

  List<Future> loadFutures = [
    preload(settingsProvider.loadAllSettings(), 'user settings'),
    preload(foodTruckProvider.retrieveStops(), 'food truck stops'),
    preload(movieNightProvider.retrieveMovies(), 'movie night listing'),
  ];

  bool diningHallComplete;
  Future diningHallFuture = diningHallProvider.retrieveDiningList()
      .then((_) {
        diningHallComplete = true;
        return _;
      })
      .catchError((e) {
        diningHallComplete = false;
        return e;
      });

  loadFutures.add(preload(diningHallFuture, 'dining hall list'));

  await Future.wait(loadFutures);

  print('Primary data preload complete in ${DateTime.now().difference(startTime).inMilliseconds}ms');

  if (!diningHallComplete) {
    throw new Error();
  }
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

      if (e is Error) {
        print(e.stackTrace);
      }
    }

    print('Preloaded all menus for ${menuDate.weekday}');

    menuDate.forward();
  }

  print('Preloaded all dining hall menus.');
}