import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';

class WidgetUtil {
  static Widget createMapsButton(String query, [String text = 'VIew in Maps']) {
    return new FlatButton(
        child: new Row(
            children: <Widget>[
              new Icon(Icons.location_on),
              new Text(text)
            ]
        ),
        onPressed: () async {
          AndroidIntent androidIntent = new AndroidIntent(
              action: 'action_view',
              data: 'https://www.google.com/maps/search/?api=1&query=${query.split(' ').join('+')}'
          );

          await androidIntent.launch();
        }
    );
  }
}