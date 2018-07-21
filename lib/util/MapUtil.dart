class MapUtil {
  static List<List<dynamic>> getEntries<K, V>(Map<K, V> map) {
    List<List<dynamic>> entries = new List();

    map.forEach((k, v) {
        entries.add([k, v]);
    });

    return entries;
  }

  static Map mapValues<K, V>(Map<K, V> from, mapper(V val)) {
    if (from == null) {
      return null;
    }

    return new Map.fromIterables(from.keys, from.values.map((v) => mapper(v)));
  }
}