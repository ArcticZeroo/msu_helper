import 'package:flutter/material.dart';

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
      home: new Homepage()
    );
  }
}