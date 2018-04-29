import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
class PageData {
  final String reloadName;
  final String bottomBarTitle;
  final Icon bottomBarIcon;
  final String appBarTitle;
  final Widget page;

  PageData({
    this.bottomBarIcon,
    this.bottomBarTitle,
    this.appBarTitle,
    this.page,
    this.reloadName
  });
}