import 'dart:async';

import 'package:meta/meta.dart';

import './provider.dart' as settingProvider;

abstract class SettingData<T> {
  final String key;
  final String title;
  final String description;
  final T defaultValue;

  const SettingData({
    @required this.key,
    this.title,
    this.description,
    this.defaultValue
  });

  T decode(String from);
  String encode(T from);

  Future<T> retrieve() async {
    return settingProvider.retrieveSetting(this);
  }

  Future save(T value) {
    return settingProvider.saveSetting(this, value);
  }
}

class StringSetting extends SettingData<String> {
  const StringSetting({
    @required String key,
    String title,
    String description,
    String defaultValue
  }) : super(
      key: key,
      title: title,
      description: description,
      defaultValue: defaultValue
  );

  @override
  String decode(String from) => from;

  @override
  String encode(String from) => from;
}

class BooleanSetting extends SettingData<bool> {
  const BooleanSetting({
    @required String key,
    String title,
    String description,
    bool defaultValue
  }) : super(
      key: key,
      title: title,
      description: description,
      defaultValue: defaultValue
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
  const DropdownSetting({
    @required String key,
    String title,
    String description,
    String defaultValue
  }) : super(
      key: key,
      title: title,
      description: description,
      defaultValue: defaultValue
  );
}