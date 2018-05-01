import 'package:msu_helper/api/settings/setting_data.dart';

class SettingsConfig {
  static const SettingData favoriteDiningHall = const StringSetting(
      key: 'favoriteDiningHall',
      title: 'Favorite Dining Hall',
      description: 'Select your favorite dining hall!',
  );

  static const SettingData collapseHours = const BooleanSetting(
    key: 'favoriteDiningHall'
  );

  static const List<SettingData> allSettings = const [favoriteDiningHall];
}