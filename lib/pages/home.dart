import 'package:flutter/material.dart';

import '../util/TextUtil.dart';

class HelperHomepage extends StatefulWidget {
  createState() => new _HelperHomepageState();
}

class _HelperHomepageState extends State<HelperHomepage> {
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