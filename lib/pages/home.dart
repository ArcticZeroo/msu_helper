import 'package:flutter/material.dart';

import '../util/TextUtil.dart';

class Homepage extends StatefulWidget {
  createState() => new _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map<double, Widget> infoWidgets = new Map();

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          title: TextUtil.getAppBarTitle('Home')
      ),
      body: new Center(
        child: new Text('Hello world!'),
      ),
    );
  }
}