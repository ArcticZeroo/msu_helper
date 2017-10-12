import 'package:flutter/material.dart';

import './util/TextUtil.dart';
import './pages/home.dart';

void main() {
  runApp(new MsuHelperApp());
}

class MsuHelperApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      color: Colors.blue,
      title: APP_TITLE,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (BuildContext context) => new HelperHomepage(),
        '/foodtruck': (BuildContext context) => new HelperHomepage()
      }
    );
  }
}