import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/structures/dining_hall/dining_hall_venue.dart';

part 'dining_hall_menu.g.dart';

@JsonSerializable()
class DiningHallMenu extends Object with _$DiningHallMenuSerializerMixin {
  DiningHallMenu({
    this.closed, this.venues
  });

  final bool closed;
  final List<DiningHallVenue> venues;

  factory DiningHallMenu.fromJson(Map<String, dynamic> json) => _$DiningHallMenuFromJson(json);
}