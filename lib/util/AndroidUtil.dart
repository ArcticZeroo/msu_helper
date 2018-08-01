import 'dart:async';
import 'dart:io' show Platform;

import 'package:android_intent/android_intent.dart';

class AndroidUtil {
  static Future launchIntent(AndroidIntent intent) async {
    if (!Platform.isAndroid) {
      return;
    }

    await intent.launch();
  }
}