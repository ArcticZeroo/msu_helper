import 'package:flutter/material.dart';
import 'package:msu_helper/pages/main_page.dart';

class HomePage extends StatefulWidget {
  final MainPageState mainPage;

  HomePage(this.mainPage);

  @override
  State<StatefulWidget> createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text('Home Page')
    );
  }
}