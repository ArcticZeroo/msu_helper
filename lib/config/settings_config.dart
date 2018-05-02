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

  static const SettingData collapseVenuesByDefault = const BooleanSetting(
      key: 'diningHall_collapseVenuesByDefault',
      defaultValue: false,
      title: 'Collapse Venues By Default',
      description: 'If you have a favorite venue, don\'t let the '
          'others take up your precious space!'
  );

  static const SettingData showHallHours = const BooleanSetting(
      key: 'diningHall_showHallHours',
      defaultValue: true,
      title: 'Show Hall Hours',
      description: 'Those pesky dining hall hours take up precious real estate.'
  );

  static const SettingData intelligentVenueOrdering = const BooleanSetting(
      key: 'diningHall_intelligentVenueOrdering',
      defaultValue: true,
      title: 'Intelligent Venue Ordering',
      description: 'If this is enabled, venues will be ordered based on how many "unique" items it has. '
          'This means a venue where the items always stay the same will be on the bottom.'
  );

  static const List<SettingData> allSettings = const [
    favoriteDiningHall, collapseDiningHallHours, showVenueDescriptions, collapseVenuesByDefault,
    showHallHours, intelligentVenueOrdering
  ];
}