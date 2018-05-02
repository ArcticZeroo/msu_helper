import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_venue.dart';

part './dining_hall_menu.g.dart';

@JsonSerializable()
class DiningHallMenu extends Object with _$DiningHallMenuSerializerMixin {
  @JsonKey(ignore: true)
  final DiningHall diningHall;

  DiningHallMenu({
    this.closed, this.venues, this.diningHall
  });

  final bool closed;
  final List<DiningHallVenue> venues;

  factory DiningHallMenu.fromJson(Map<String, dynamic> json) => _$DiningHallMenuFromJson(json);

  DiningHallMenu copyWith({ bool closed, List<DiningHallVenue> venues, DiningHall diningHall }) {
    return new DiningHallMenu(
      closed: closed ?? this.closed,
      venues: venues ?? this.venues,
      diningHall: diningHall ?? this.diningHall
    );
  }
}