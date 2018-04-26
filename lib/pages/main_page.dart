import 'package:flutter/material.dart';
import 'package:msu_helper/api/page_data.dart';
import 'package:msu_helper/widgets/bottom_bar.dart';

class MainPage extends StatefulWidget {
  final MainBottomBar bottomBar;

  MainPage() : this.bottomBar = new MainBottomBar() {
    bottomBar.addPage(new PageData(
        appBarTitle: 'MSU Helper Home',
        bottomBarTitle: 'Home',
        bottomBarIcon: new Icon(Icons.home),
        page: this
    ));

    bottomBar.addPage(new PageData(
        appBarTitle: 'Dining Hall Info',
        bottomBarTitle: 'Dining Halls',
        bottomBarIcon: new Icon(Icons.restaurant_menu),
        page: this
    ));
  }

  @override
  State<StatefulWidget> createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.bottomBar.getPageData().appBarTitle),
      ),
      body: widget.bottomBar.getPage(),
      bottomNavigationBar: widget.bottomBar.build(setState)
    );
  }
}