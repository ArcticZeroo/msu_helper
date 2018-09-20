import 'package:json_annotation/json_annotation.dart';

part './food_truck_menu_item.g.dart';

@JsonSerializable()
class FoodTruckMenuItem extends Object with _$FoodTruckMenuItemSerializerMixin {
  final String name;
  final String description;
  final double price;

  FoodTruckMenuItem({this.name, this.description, this.price});

  static FoodTruckMenuItem fromJson(Map<String, dynamic> json) => _$FoodTruckMenuItemFromJson(json);
}