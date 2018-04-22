class PageRoute {
  static const String ROOT = 'https://frozor.io/api/';
  static const String MSU = 'msu/';
  static const String DINING = 'dining/';
  static const String DINING_LIST = 'list/';
  static const String DINING_MENU = 'menu/';

  static String getDining(String end) {
    return PageRoute.ROOT + PageRoute.MSU + PageRoute.DINING + end;
  }
}