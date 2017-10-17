import 'package:flutter/material.dart';
import 'package:msu_helper/pages/settings.dart';

import './util/TextUtil.dart';
import './pages/home.dart';

void main() {
  runApp(new MsuHelperApp());
}

class MsuHelperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      color: Colors.green,
      title: APP_TITLE,
      theme: new ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.greenAccent
      ),
      routes: {
        '/': (BuildContext context) => new Homepage(),
        '/foodtruck': (BuildContext context) => new Homepage(),
        '/settings': (BuildContext context) => new SettingsPage()
      }
    );
  }
}