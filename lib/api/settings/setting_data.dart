import 'dart:async';

import 'package:meta/meta.dart';

import './provider.dart' as settingProvider;

abstract class SettingData<T> {
  final String key;
  final String title;
  final String description;

  const SettingData({
    @required this.key,
    @required this.title,
    @required this.description
  });

  T decode(String from);
  String encode(T from);

  Future<T> retrieve() async {
    String value = await settingProvider.retrieveSetting(this);

    return decode(value);
  }

  Future save(T value) {
    return settingProvider.saveSetting(this, value);
  }
}

class StringSetting extends SettingData<String> {
  const StringSetting({
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
  const BooleanSetting({
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
  const DropdownSetting({
    @required String key,
    @required String title,
    @required String description,
  }) : super(
      key: key,
      title: title,
      description: description
  );
}