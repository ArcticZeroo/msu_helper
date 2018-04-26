import 'package:flutter/material.dart';

class PageData {
  final String bottomBarTitle;
  final Icon bottomBarIcon;
  final String appBarTitle;
  final Widget page;

  PageData({
    this.bottomBarIcon,
    this.bottomBarTitle,
    this.appBarTitle,
    this.page
  });
}