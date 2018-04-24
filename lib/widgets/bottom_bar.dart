import 'package:flutter/material.dart';
import 'dart:math' show min;

class MainBottomBar {
  List<Widget> _pages = [];
  List<Icon> _icons = [];
  List<String> _titles = [];

  int _position = 0;

  getPage() {
    return _pages[_position];
  }

  List<BottomNavigationBarItem> buildItems() {
    List<BottomNavigationBarItem> items = [];

    // Juuuust in case one of them is smaller for some reason.
    for (int i = 0; i < min(_titles.length, _icons.length); i++) {
      items.add(new BottomNavigationBarItem(
          icon: _icons[i],
          title: new Text(_titles[i])
      ));
    }

    return items;
  }

  BottomNavigationBar build(Function setState) {
    return new BottomNavigationBar(
      currentIndex: _position,
      items: [],
      onTap: (int index) {
        setState(() {
          _position = index;
        });
      },
    );
  }

  void addPage(String title, Icon icon, Widget page) {
    _pages.add(page);
    _icons.add(icon);
    _titles.add(title);
  }
}