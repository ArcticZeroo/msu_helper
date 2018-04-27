import 'dart:async';

import 'package:meta/meta.dart';

import './provider.dart' as settingProvider;

abstract class SettingData<T> {
  String key;
  String title;
  String description;
  SettingDisplayType displayType;

  SettingData({
    @required this.key,
    @required this.title,
    @required this.description,
    @required this.displayType
  });

  T decode(String from);
  String encode(T from);

  Future<T> retrieve() {
    return settingProvider.retrieveSettingFromDb(this);
  }

  Future save(T value) {
    return settingProvider.saveSettingToDb(this, value);
  }
}

class StringSetting extends SettingData<String> {
  @override
  String decode(String from) => from;

  @override
  String encode(String from) => from;
}

class BooleanSetting extends SettingData<bool> {
  @override
  bool decode(String from) {
    return from.toLowerCase() == 'true';
  }

  @override
  String encode(bool from) {
    return from.toString();
  }
}

enum SettingDisplayType {
  checkbox, dropdown
}