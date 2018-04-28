class Meal {
  static const Meal breakfast = Meal._internal(name: 'Breakfast', identifier: 192);
  static const Meal lunch = Meal._internal(name: 'Lunch', identifier: 190);
  static const Meal dinner = Meal._internal(name: 'Dinner', identifier: 191);
  static const Meal lateNight = Meal._internal(name: 'Late Night', identifier: 232);

  static final List<Meal> meal = new List.unmodifiable([
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
    print(meal);
    print('Getting meal from ordinal $i');
    return meal[i];
  }

  static int get count => meal.length;
}