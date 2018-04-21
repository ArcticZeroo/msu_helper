import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/structures/dining_hall/food_item.dart';

part 'dining_hall_venue.g.dart';

@JsonSerializable()
class DiningHallVenue extends Object with _$DiningHallVenueSerializerMixin {
  DiningHallVenue({
    this.venueName, this.description, this.menu
  });

  final String venueName;
  final String description;
  final List<FoodItem> menu;

  factory DiningHallVenue.fromJson(Map<String, dynamic> json) => _$DiningHallVenueFromJson(json);
}