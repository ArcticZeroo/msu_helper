import 'package:msu_helper/api/dining_hall/time.dart';
import 'package:msu_helper/config/identifier.dart';
import 'package:msu_helper/widgets/preloading/preload_widget.dart';
import 'package:msu_helper/api/dining_hall/provider.dart' as diningHallProvider;
import 'package:msu_helper/api/food_truck/provider.dart' as foodTruckProvider;
import 'package:msu_helper/api/movie_night/provider.dart' as movieNightProvider;
import 'package:msu_helper/api/settings/provider.dart' as settingsProvider;

class Preloaders {
  static final instance = Preloaders._internal();

  final Map<String, PreloadingWidget> primaryLoaders = {};
  final Map<String, PreloadingWidget> secondaryLoaders = {};

  Preloaders._internal() {
    primaryLoaders[Identifier.settings] = new PreloadingWidget('Your Settings', settingsProvider.loadAllSettings);
    primaryLoaders[Identifier.foodTruck] = new PreloadingWidget('Food Truck Stops', foodTruckProvider.retrieveStops);
    primaryLoaders[Identifier.foodTruckMenu] = new PreloadingWidget('Food Truck Menus', foodTruckProvider.retrieveMenus);
    primaryLoaders[Identifier.movieNight] = new PreloadingWidget('Movie Night Listings', movieNightProvider.retrieveMovies);
    primaryLoaders[Identifier.diningHall] = new PreloadingWidget(
      'Available Dining Halls + Hours',
      diningHallProvider.retrieveDiningList);

    secondaryLoaders[Identifier.diningHall] = new PreloadingWidget('Dining Hall Menus', preloadHallMenus);
  }

  Future preloadMenusForDay(MenuDate menuDate) async {
    print('Preloading menus for ${menuDate.weekday} from the web');

    try {
      await diningHallProvider.retrieveMenusForDayFromWeb(menuDate);
    } catch (e) {
      throw e;
    }

    print('Preloaded menus for ${menuDate.weekday}');
  }

  Future preloadHallMenus() async {
    print('Preloading secondary data...');

    MenuDate menuDate = MenuDate.now();
    List<Future> menuFutures = <Future>[];

    // For the next 3 days in the week (more can be loaded in demand)
    for (int i = 0; i < 3; i++) {
      menuFutures.add(preloadMenusForDay(menuDate));

      menuDate = menuDate.forward();
    }

    try {
      await Future.wait(menuFutures);

      print('Preloaded all menus');
    } catch (e) {
      print('Could not preload menus:');

      if (e is Error) {
        print(e.stackTrace);
      } else {
        print(e.toString());
      }

      menuFutures.forEach((future) => future.timeout(new Duration()));
    }

    print('Preloaded all dining hall menus.');
  }
}