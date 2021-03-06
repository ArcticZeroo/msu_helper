class ListUtil {
  static List<T> mapAllButFirst<T>(List<T> list, Function map) {
    List<T> mapped = [list.first];
    mapped.addAll(list.sublist(1, list.length).map(map));
    return mapped;
  }

  static List<T> add<T>(List<T> list, dynamic v) {
    List<T> copy = List.from(list);

    if (v is List<T>) {
      copy.addAll(v);
    } else if (v is T) {
      copy.add(v);
    } else {
      throw new TypeError();
    }

    return copy;
  }

  static void insertBetween<T>(List<T> list, T e) {
    for (int i = 0; i < list.length - 2; i += 2) {
      list.insert(i, e);
    }
  }
}