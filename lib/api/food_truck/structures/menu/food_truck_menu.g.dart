// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_truck_menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodTruckMenu _$FoodTruckMenuFromJson(Map<String, dynamic> json) {
  return new FoodTruckMenu(
      title: json['title'] as String,
      items: (json['items'] as List)
          ?.map((e) => e == null
              ? null
              : new FoodTruckMenuItem.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

abstract class _$FoodTruckMenuSerializerMixin {
  String get title;
  List<FoodTruckMenuItem> get items;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'title': title, 'items': items};
}
