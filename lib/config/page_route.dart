class PageRoute {
  // Root paths
  static const String ROOT = 'https://frozor.io';
  static const String API = 'api';
  static const String MSU = 'msu';

  // Category paths
  static const String DINING = 'dining';
  static const String FOOD_TRUCK = 'foodtruck';
  static const String MOVIE_NIGHT = 'movies';

  // Method paths
  static const String LIST = 'list';
  static const String MENU = 'menu';

  static String join(List<String> pieces) {
    return pieces.join('/');
  }

  static String getMsuApi() {
    return join([PageRoute.ROOT, PageRoute.API, PageRoute.MSU]);
  }

  static String getApiRoute(String route, String end) {
    return join([getMsuApi(), route, end]);
  }

  static String getDining(String end) {
    return getApiRoute(PageRoute.DINING, end);
  }

  static String getFoodTruck(String end) {
    return getApiRoute(PageRoute.FOOD_TRUCK, end);
  }

  static String getMovieNight(String end) {
    return getApiRoute(PageRoute.MOVIE_NIGHT, end);
  }
}