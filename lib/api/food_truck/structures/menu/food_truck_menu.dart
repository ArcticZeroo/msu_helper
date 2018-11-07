import 'package:json_annotation/json_annotation.dart';
import 'package:msu_helper/api/food_truck/structures/menu/food_truck_menu_item.dart';

part './food_truck_menu.g.dart';

@JsonSerializable()
class FoodTruckMenu extends Object with _$FoodTruckMenuSerializerMixin {
  final String title;
  final List<FoodTruckMenuItem> items;

  FoodTruckMenu({this.title, this.items});

  factory FoodTruckMenu.fromJson(Map<String, dynamic> json) => _$FoodTruckMenuFromJson(json);
}