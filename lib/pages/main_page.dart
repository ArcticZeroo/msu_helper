import 'package:flutter/material.dart';
import 'package:msu_helper/api/page_data.dart';
import 'package:msu_helper/api/reloadable.dart';
import 'package:msu_helper/pages/dining_hall/dining_main_page.dart';
import 'package:msu_helper/pages/food_truck_page.dart';
import 'package:msu_helper/pages/home_page.dart';
import 'package:msu_helper/pages/settings_page.dart';
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
      page: new HomePage(bottomBar),
      reloadName: HomePage.reloadableCategory
    ));

    bottomBar.addPage(new PageData(
      appBarTitle: 'Dining Hall Info',
      bottomBarTitle: 'Dining Halls',
      bottomBarIcon: new Icon(Icons.restaurant_menu),
      page: new DiningMainPage(),
      reloadName: DiningMainPage.reloadableCategory
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
    print('Building page "${bottomBar.getPageData().bottomBarTitle}"');

    List<Widget> actions = [];

    if (bottomBar.getPageData().reloadName != null) {
      actions.add(
          new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: () {
                Reloadable.triggerReload(
                    [bottomBar.getPageData().reloadName],
                    { 'refresh': true }
                );
              }
          )
      );
    }

    actions.add(new IconButton(
        icon: new Icon(Icons.settings),
        onPressed: () async {
          await Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new SettingsPage())
          );
          print('Settings was closed');
          /*setState(() {
            print('Rebuilding as a result');
          });*/
          Reloadable.triggerReload([SettingsPage.reloadableCategory]);
        }
    ));

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(bottomBar.getPageData().appBarTitle),
          actions: actions,
        ),
        body: bottomBar.getPage(),
        bottomNavigationBar: bottomBar.build()
    );
  }
}