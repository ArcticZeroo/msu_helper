import 'package:flutter/material.dart';

abstract class Reloadable<T extends StatefulWidget> extends State<T> {
  static const String defaultCategory = 'none';
  static final Map<String, List<Reloadable>> _reloadables = new Map();

  static List<String> get categoryNames => _reloadables.keys.toList();

  final List<String> _categories;
  bool _disposed = false;

  Reloadable([List<String> categories = const [defaultCategory]])
      : _categories = categories.map((c) => c.toLowerCase()).toList();


  bool get canSetState => !_disposed && mounted;

  @override
  void initState() {
    super.initState();
    for (String category in _categories) {
      if (!_reloadables.containsKey(category)) {
        _reloadables[category] = new List<Reloadable>();
      }

      _reloadables[category].add(this);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    for (String category in _categories) {
      _reloadables[category].remove(this);
    }
  }

  void reload(Map<String, dynamic> params) {
    setState(() {});
  }

  static void triggerReload([List<String> categories = const [defaultCategory], Map<String, dynamic> params = const {}]) {
    print('[Reloadable] triggering reload of categories $categories');

    Set<Reloadable> reloaded = new Set();

    for (String category in categories) {
      category = category.toLowerCase();

      if (!_reloadables.containsKey(category)) {
        continue;
      }

      List<Reloadable> reloadablesInCategory  = _reloadables[category];

      for (Reloadable reloadable in reloadablesInCategory) {
        // Prevent reloading a State more than once
        // per call of triggerReload
        if (reloaded.contains(reloadable)) {
          continue;
        }

        if (!reloadable.canSetState) {
          continue;
        }

        reloadable.reload(params);
        reloaded.add(reloadable);
      }
    }
  }

  static void triggerReloadForAll([Map<String, dynamic> params = const {}]) {
    triggerReload(categoryNames, params);
  }
}