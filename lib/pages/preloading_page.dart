import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msu_helper/api/settings/provider.dart' as settingsProvider;
import 'package:msu_helper/config/identifier.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/loaders/preloaders.dart';
import 'package:msu_helper/widgets/preloading/preload_widget.dart';
import 'package:msu_helper/widgets/visibility_toggle.dart';

class PreloadingPage extends StatelessWidget {
  final Map<String, PreloadingWidget> primaryLoaders = Preloaders.instance.primaryLoaders;
  final Map<String, PreloadingWidget> secondaryLoaders = Preloaders.instance.secondaryLoaders;

  Future preloadPrimary() async {
    print('---------------');
    print('Primary preload initializing...');

    Iterable<Future> loaders = primaryLoaders.values
      .map((preloader) => preloader.future.value);

    try {
      await Future.wait(loaders);
    } catch (e) {
      print('Could not load a primary loader');

      if (e is Error) {
        print(e.stackTrace);
      } else {
        print(e.toString());
      }
    }

    print('Primary preload complete');
    print('---------------');
  }

  Future preloadSecondary() async {
    print('---------------');
    print('Secondary preload initializing...');

    try {
      await secondaryLoaders[Identifier.diningHall].start();
    } catch (e) {
      print('Loading of dining hall menus failed: $e');
    }

    print('Secondary preload complete');
    print('---------------');
  }

  Future preload() async {
    Future primaryPreloadFuture = preloadPrimary();

    try {
      await primaryLoaders[Identifier.diningHall].future.value;
    } catch (e) {
      // If dining halls did not load, just finish waiting for the rest,
      // and then we can skip the menu loading
      print('Dining halls failed to load, waiting for rest to finish');
      await primaryPreloadFuture;
      return;
    }

    await Future.wait([primaryPreloadFuture, preloadSecondary()]);
  }

  void openHomePage(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    bool hasGoneHome = false;

    var goHome = () {
      if (hasGoneHome) {
        return;
      }
      openHomePage(context);
      hasGoneHome = true;
    };

    VisibilityToggleWidget skipButton = new VisibilityToggleWidget(
        child: new RaisedButton(
            color: Colors.blue,
            child: new Text('Skip'),
            onPressed: goHome,
            textColor: Colors.white),
        isInitiallyVisible: false);

    List<Widget> columnChildren = <Widget>[
      new Container(
        decoration: new BoxDecoration(
            color: Colors.green[600],
            borderRadius: const BorderRadius.all(const Radius.circular(6.0))),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: new Column(
          children: <Widget>[
            new Text('Pre-loading data...',
                style: new TextStyle(fontSize: 22.0, color: Colors.white)),
            new Container(
              margin: const EdgeInsets.only(top: 4.0),
              child: new Text('Shouldn\'t be long!',
                  style: new TextStyle(color: Colors.grey[200])),
            )
          ],
        ),
      ),
      new Card(
        child: new Column(
            children: <Widget>[]
              ..addAll(primaryLoaders.values)
              ..addAll(secondaryLoaders.values)),
      ),
      skipButton
    ];

    primaryLoaders[Identifier.settings].future.addListener(() {
      Future settingsFuture = primaryLoaders[Identifier.settings].future.value;

      settingsFuture.then((v) {
        if (settingsProvider
            .getCached(SettingsConfig.skipPreloadAutomatically)) {
          goHome();
        } else {
          skipButton.isVisible = true;
        }

        return v;
      });
    });

    preload().timeout(new Duration(seconds: 15)).whenComplete(goHome);

    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(color: Colors.grey[200]),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: columnChildren,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }
}
