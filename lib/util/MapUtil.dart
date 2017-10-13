class MapUtil {
  static List<List<dynamic>> getEntries<T>(Map<T, T> map) {
    List<List<dynamic>> entries = new List();

    map.forEach((k, v) {
        entries.add([k, v]);
    });

    return entries;
  }
}