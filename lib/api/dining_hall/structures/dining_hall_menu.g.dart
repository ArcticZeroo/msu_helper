// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dining_hall_menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiningHallMenu _$DiningHallMenuFromJson(Map<String, dynamic> json) =>
    new DiningHallMenu(
        closed: json['closed'] as bool,
        venues: (json['venues'] as List)
            ?.map((e) => e == null
                ? null
                : new DiningHallVenue.fromJson(e as Map<String, dynamic>))
            ?.toList());

abstract class _$DiningHallMenuSerializerMixin {
  bool get closed;
  List<DiningHallVenue> get venues;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'closed': closed, 'venues': venues};
}
