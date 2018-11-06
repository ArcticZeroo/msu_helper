import 'package:json_annotation/json_annotation.dart';

part './food_truck_menu_item.g.dart';

double doubleFromJson(String from) => double.parse(from);

@JsonSerializable()
class FoodTruckMenuItem extends Object with _$FoodTruckMenuItemSerializerMixin {
  final String name;
  final String description;
  @JsonKey(fromJson: doubleFromJson)
  final double price;

  FoodTruckMenuItem({this.name, this.description, this.price});

  factory FoodTruckMenuItem.fromJson(Map<String, dynamic> json) => _$FoodTruckMenuItemFromJson(json);
}