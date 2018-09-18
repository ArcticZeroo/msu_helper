class PageRouteConfig {
  // Root paths
  static const String ROOT = 'https://frozor.io';
  // static const String ROOT = 'http://localhost';
  static const String API = 'api';
  static const String MSU = 'msu';

  // Category paths
  static const String DINING = 'dining';
  static const String FOOD_TRUCK = 'foodtruck';
  static const String MOVIE_NIGHT = 'movies';

  // Method paths
  static const String LIST = 'list';
  static const String MENU = 'menu';

  // User-facing pages to link them
  static const String USER_MOVIES_RHA = "http://rha.msu.edu/programs/campus-center-cinemas.html";

  static String join(List<String> pieces) {
    return pieces.join('/');
  }

  static String getMsuApi() {
    return join([PageRouteConfig.ROOT, PageRouteConfig.API, PageRouteConfig.MSU]);
  }

  static String getApiRoute(String route, String end) {
    return join([getMsuApi(), route, end]);
  }

  static String getDining(String end) {
    return getApiRoute(PageRouteConfig.DINING, end);
  }

  static String getFoodTruck(String end) {
    return getApiRoute(PageRouteConfig.FOOD_TRUCK, end);
  }

  static String getMovieNight(String end) {
    return getApiRoute(PageRouteConfig.MOVIE_NIGHT, end);
  }
}