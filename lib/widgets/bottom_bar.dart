import 'package:flutter/material.dart';
import 'dart:math' show min;

import 'package:msu_helper/api/page_data.dart';

class MainBottomBar {
  static final MainBottomBar _mainBar = MainBottomBar._internal();

  factory MainBottomBar() {
    return _mainBar;
  }

  MainBottomBar._internal();

  List<PageData> _pages = [];

  int _position = 0;

  PageData getPageData() {
    return _pages[_position];
  }

  Widget getPage() {
    return getPageData().page;
  }

  List<BottomNavigationBarItem> buildItems() {
    List<BottomNavigationBarItem> items = [];

    // Juuuust in case one of them is smaller for some reason.
    for (int i = 0; i < _pages.length; i++) {
      items.add(new BottomNavigationBarItem(
          icon: _pages[i].bottomBarIcon,
          title: new Text(_pages[i].bottomBarTitle)
      ));
    }

    return items;
  }

  BottomNavigationBar build(Function setState) {
    return new BottomNavigationBar(
      currentIndex: _position,
      items: buildItems(),
      onTap: (int index) {
        setState(() {
          _position = index;
        });
      },
    );
  }

  void addPage(PageData pageData) {
    _pages.add(pageData);
  }
}