import 'package:flutter/material.dart';

const String APP_TITLE = 'MSU Helper';

class TextUtil {
  static getAppBarTitle(String text) {
    return new Text('$APP_TITLE - $text');
  }
}