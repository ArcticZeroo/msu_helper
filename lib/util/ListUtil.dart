class ListUtil {
  static List<T> mapAllButFirst<T>(List<T> list, Function map) {
    List<T> mapped = [list.first];
    mapped.addAll(list.sublist(1, list.length).map(map));
    return mapped;
  }
}