import 'dart:async';
import 'dart:io' show Platform;

import 'package:android_intent/android_intent.dart';

class AndroidUtil {
  static Future openMaps(String query) async {
    if (!Platform.isAndroid) {
      return;
    }

    AndroidIntent androidIntent = new AndroidIntent(
        action: 'action_view',
        data: 'https://www.google.com/maps/search/?api=1&query=${query.split(' ').join('+')}'
    );

    await androidIntent.launch();
  }
}