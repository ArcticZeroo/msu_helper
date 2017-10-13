class Pages {
  static const String BASE_URL = "localhost";
  static const String FOOD_TRUCK = "/api/foodtruck/where";

  static String getUrl(String page) {
    return Pages.BASE_URL + page;
  }
}