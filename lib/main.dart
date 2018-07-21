import 'package:flutter/material.dart';
import 'package:msu_helper/api/preloader.dart';
import 'package:msu_helper/pages/home_page.dart';
import 'package:msu_helper/pages/preloading_page.dart';

import './util/TextUtil.dart';
import './pages/main_page.dart';

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
        '/': (context) => new PreloadingPage(),
        'home': (context) => new MainPage()
      },
    );
  }
}