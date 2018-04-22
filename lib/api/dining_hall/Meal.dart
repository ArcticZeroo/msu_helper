class Meal {
  static List<Meal> _meals = [];

  final String name;
  final int identifier;
  int _ordinal;

  get ordinal => _ordinal;

  Meal._internal({ this.name, this.identifier }) {
    _ordinal = _meals.length;
    _meals.add(this);
  }

  static final Meal breakfast = Meal._internal(name: 'Breakfast', identifier: 192);
  static final Meal lunch = Meal._internal(name: 'Lunch', identifier: 190);
  static final Meal dinner = Meal._internal(name: 'Dinner', identifier: 191);
  static final Meal lateNight = Meal._internal(name: 'Late Night', identifier: 232);

  static fromOrdinal(int i) {
    return _meals[i];
  }

  static get count => _meals.length;
}