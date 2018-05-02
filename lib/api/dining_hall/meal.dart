class Meal {
  static const Meal breakfast = Meal._internal(name: 'Breakfast', identifier: 192, ordinal: 0);
  static const Meal lunch = Meal._internal(name: 'Lunch', identifier: 190, ordinal: 1);
  static const Meal dinner = Meal._internal(name: 'Dinner', identifier: 191, ordinal: 2);
  static const Meal lateNight = Meal._internal(name: 'Late Night', identifier: 232, ordinal: 3);

  static final List<Meal> _meal = new List.unmodifiable([
    Meal.breakfast, Meal.lunch, Meal.dinner, Meal.lateNight
  ]);

  final String name;
  final int identifier;
  final int ordinal;

  const Meal._internal({ this.name, this.identifier, this.ordinal });

  @override
  String toString() {
    return "Meal($ordinal)[$name]";
  }

  static Meal fromOrdinal(int i) {
    return _meal[i];
  }

  static int get count => _meal.length;

  static List<Meal> asList() {
    return _meal;
  }
}