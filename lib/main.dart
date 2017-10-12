import 'package:flutter/material.dart';

import './util/TextUtil.dart';

void main() {
  runApp(new MsuHelperApp());
}

class MsuHelperApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: APP_TITLE,
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new HelperHomepage(),
    );
  }
}

class HelperHomepage extends StatefulWidget {
  createState() => new HelperHomepageState();
}

class HelperHomepageState extends State<HelperHomepage> {
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