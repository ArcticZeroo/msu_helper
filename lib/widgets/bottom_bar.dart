import 'package:flutter/material.dart';
import 'dart:math' show min;

import 'package:msu_helper/api/page_data.dart';

typedef void SetStateCallback(void fn());

class MainBottomBar {
  SetStateCallback setState;

  MainBottomBar(SetStateCallback setState) {
    this.setState = setState;
  }

  List<PageData> _pages = [];

  int _position = 0;

  PageData getPageData() {
    return _pages[_position];
  }

  Widget getPage() {
    return getPageData().page;
  }

  void setPage(int index) {
    setState(() {
      _position = index;
    });
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

  BottomNavigationBar build() {
    return new BottomNavigationBar(
      currentIndex: _position,
      items: buildItems(),
      onTap: (int index) {
        print('Tapped');
        setState(() {
          print('Setting state');
          _position = index;
        });
      },
    );
  }

  void addPage(PageData pageData) {
    _pages.add(pageData);
  }
}