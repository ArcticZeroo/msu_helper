import 'package:msu_helper/api/settings/setting_data.dart';

class SettingsConfig {
  static const SettingData favoriteDiningHall = const StringSetting(
      key: 'favoriteDiningHall',
      title: 'Favorite Dining Hall',
      description: 'Select your favorite dining hall!',
  );

  static const SettingData collapseDiningHallHours = const BooleanSetting(
    key: 'diningHall_collapseHours',
    defaultValue: false
  );

  static const SettingData showVenueDescriptions = const BooleanSetting(
      key: 'diningHall_showVenueDescriptions',
      defaultValue: true,
      title: 'Show Venue Descriptions',
      description: 'Some of them are pretty long. You can disable them here!'
  );

  static const List<SettingData> allSettings = const [
    favoriteDiningHall, collapseDiningHallHours, showVenueDescriptions
  ];
}