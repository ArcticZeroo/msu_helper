import 'package:flutter/material.dart';

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
    if (index == _position) {
      return;
    }

    setState(() {
      print('Setting page to $index');
      _position = index;
    });
  }

  List<BottomNavigationBarItem> buildItems() {
    List<BottomNavigationBarItem> items = [];

    for (PageData pageData in _pages) {
      items.add(new BottomNavigationBarItem(
          icon: pageData.bottomBarIcon,
          title: new Text(pageData.bottomBarTitle)
      ));
    }

    return items;
  }

  Widget build(BuildContext context) {
    BottomNavigationBar bar = new BottomNavigationBar(
      currentIndex: _position,
      items: buildItems(),
      onTap: this.setPage,
    );

    if (bar.type == BottomNavigationBarType.fixed) {
      return bar;
    }

    ThemeData contextTheme = Theme.of(context);

    return new Theme(
        data: contextTheme.copyWith(
          canvasColor: contextTheme.primaryColor
        ),
        child: bar
    );
  }

  void addPage(PageData pageData) {
    _pages.add(pageData);
  }
}