import 'dart:async';

import 'package:meta/meta.dart';

import './provider.dart' as settingProvider;

abstract class SettingData<T> {
  String key;
  String title;
  String description;

  SettingData({
    @required this.key,
    @required this.title,
    @required this.description
  });

  T decode(String from);
  String encode(T from);

  Future<T> retrieve() async {
    String value = await settingProvider.retrieveSettingFromDb(this);

    return decode(value);
  }

  Future save(T value) {
    return settingProvider.saveSettingToDb(this, value);
  }
}

class StringSetting extends SettingData<String> {
  StringSetting({
    @required String key,
    @required String title,
    @required String description,
  }) : super(
      key: key,
      title: title,
      description: description
  );

  @override
  String decode(String from) => from;

  @override
  String encode(String from) => from;
}

class BooleanSetting extends SettingData<bool> {
  BooleanSetting({
    @required String key,
    @required String title,
    @required String description,
  }) : super(
      key: key,
      title: title,
      description: description
  );

  @override
  bool decode(String from) {
    return from.toLowerCase() == 'true';
  }

  @override
  String encode(bool from) {
    return from.toString();
  }
}

class DropdownSetting extends StringSetting {
  DropdownSetting({
    @required String key,
    @required String title,
    @required String description,
  }) : super(
      key: key,
      title: title,
      description: description
  );
}