// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dining_hall_venue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiningHallVenue _$DiningHallVenueFromJson(Map<String, dynamic> json) {
  return new DiningHallVenue(
      name: json['venueName'] as String,
      description: json['description'] as String,
      menu: (json['menu'] as List)
          ?.map((e) => e == null
              ? null
              : new FoodItem.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

abstract class _$DiningHallVenueSerializerMixin {
  String get name;
  String get description;
  List<FoodItem> get menu;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'venueName': name,
        'description': description,
        'menu': menu
      };
}
