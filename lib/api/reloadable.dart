import 'package:flutter/material.dart';

abstract class Reloadable<T extends StatefulWidget> extends State<T> {
  static const String defaultCategory = 'none';
  static final Map<String, List<Reloadable>> _reloadables = new Map();

  static List<String> get categoryNames => _reloadables.keys.toList();

  final List<String> _categories;

  Reloadable([List<String> categories = const [defaultCategory]])
      : _categories = categories.map((c) => c.toLowerCase()).toList() {
    for (String category in _categories) {
      if (!_reloadables.containsKey(category)) {
        _reloadables[category] = new List<Reloadable>();
      }

      _reloadables[category].add(this);
    }
  }

  void reload() {
    setState(() {});
  }

  static void triggerReload([List<String> categories = const [defaultCategory]]) {
    print('[Reloadable] triggering reload of categories $categories');

    List<Reloadable> reloaded = new List();

    for (String category in categories) {
      category = category.toLowerCase();

      if (!_reloadables.containsKey(category)) {
        continue;
      }

      List<Reloadable> reloadablesInCategory  = _reloadables[category];

      for (Reloadable reloadable in reloadablesInCategory) {
        // Prevent reloading a State more than once
        if (reloaded.contains(reloadable)) {
          continue;
        }

        reloadable.reload();
        reloaded.add(reloadable);
      }
    }
  }

  static void triggerReloadForAll() {
    triggerReload(categoryNames);
  }
}