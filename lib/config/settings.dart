import 'package:msu_helper/api/settings/setting_data.dart';

class SettingsConfig {
  static final SettingData favoriteDiningHall = new StringSetting(
      key: 'favoriteDiningHall',
      title: 'Favorite Dining Hall',
      description: 'Select your favorite dining hall!',
  );
}