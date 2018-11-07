// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_truck_menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodTruckMenuItem _$FoodTruckMenuItemFromJson(Map<String, dynamic> json) {
  return new FoodTruckMenuItem(
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] == null
          ? null
          : doubleFromJson(json['price'] as String));
}

abstract class _$FoodTruckMenuItemSerializerMixin {
  String get name;
  String get description;
  double get price;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'description': description,
        'price': price
      };
}
