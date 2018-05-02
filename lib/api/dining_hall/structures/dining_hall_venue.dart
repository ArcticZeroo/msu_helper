import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/structures/food_item.dart';

part './dining_hall_venue.g.dart';

@JsonSerializable()
class DiningHallVenue extends Object with _$DiningHallVenueSerializerMixin {
  DiningHallVenue({
    this.name, this.description, this.menu
  });

  @JsonKey(name: 'venueName')
  final String name;
  final String description;
  final List<FoodItem> menu;

  factory DiningHallVenue.fromJson(Map<String, dynamic> json) => _$DiningHallVenueFromJson(json);
}