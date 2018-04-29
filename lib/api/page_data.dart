import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
class PageData {
  final String bottomBarTitle;
  final Icon bottomBarIcon;
  final String appBarTitle;
  final Widget page;
  final List<Widget> appBarActions;

  PageData({
    this.bottomBarIcon,
    this.bottomBarTitle,
    this.appBarTitle,
    this.page,
    this.appBarActions
  });
}