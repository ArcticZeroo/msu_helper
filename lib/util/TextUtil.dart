import 'package:flutter/material.dart';

const String APP_TITLE = 'MSU Helper';

const List<String> PRETTY_SPECIAL = const ['zeroth', 'first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth', 'eleventh', 'twelfth', 'thirteenth', 'fourteenth', 'fifteenth', 'sixteenth', 'seventeenth', 'eighteenth', 'nineteenth'];

const List<String> PRETTY_TENS = const ['twent', 'thirt', 'fort', 'fift', 'sixt', 'sevent', 'eight', 'ninet'];

class TextUtil {
  static getAppBarTitle(String text) {
    return new Text('$APP_TITLE - $text');
  }

  static prettifyNum(int num) {
    if (num < 20) {
      return PRETTY_SPECIAL[num];
    }

    int decaIndex = (num / 10).floor() - 2;

    if (num % 10 == 0) {
      return PRETTY_TENS[decaIndex] + 'ieth';
    }

    return PRETTY_TENS[decaIndex] + 'y-' + PRETTY_SPECIAL[num % 10];
  }
}