class Pages {
  static const String BASE_URL = "https://frozor.io";
  static const String FOOD_TRUCK = "/api/foodtruck/where";
  static const String MOVIE_NIGHT = "/api/msu/movies";

  static String getUrl(String page) {
    return Pages.BASE_URL + page;
  }
}