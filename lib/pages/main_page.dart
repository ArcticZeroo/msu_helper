import 'package:flutter/material.dart';
import 'package:msu_helper/api/page_data.dart';
import 'package:msu_helper/pages/dining_hall.dart';
import 'package:msu_helper/pages/food_truck.dart';
import 'package:msu_helper/pages/home_page.dart';
import 'package:msu_helper/widgets/bottom_bar.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MainPageState();
}

/// The main page of the app. This page is used to
/// control the current view of the app, including
/// the bottom bar and transitioning between pages
/// & AppBar titles.
class MainPageState extends State<MainPage> {
  /// The primary bottom bar for this app.
  MainBottomBar bottomBar;

  MainPageState() {
    bottomBar = new MainBottomBar(this.setState);

    bottomBar.addPage(new PageData(
        appBarTitle: 'MSU Helper Home',
        bottomBarTitle: 'Home',
        bottomBarIcon: new Icon(Icons.home),
        page: new HomePage(this)
    ));

    bottomBar.addPage(new PageData(
        appBarTitle: 'Dining Hall Info',
        bottomBarTitle: 'Dining Halls',
        bottomBarIcon: new Icon(Icons.restaurant_menu),
        page: new DiningHallPage()
    ));

    bottomBar.addPage(new PageData(
        appBarTitle: 'Food Truck Stops',
        bottomBarTitle: 'Food Truck',
        bottomBarIcon: new Icon(Icons.local_shipping),
        page: new FoodTruckPage()
    ));
  }

  @override
  Widget build(BuildContext context) {
    print('Building page');
    print(bottomBar.getPage().toString());

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(bottomBar.getPageData().appBarTitle),
      ),
      body: bottomBar.getPage(),
      bottomNavigationBar: bottomBar.build()
    );
  }
}