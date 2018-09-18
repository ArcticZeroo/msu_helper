// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodItem _$FoodItemFromJson(Map<String, dynamic> json) {
  return new FoodItem(
      name: json['name'] as String,
      preferences:
          (json['preferences'] as List)?.map((e) => e as String)?.toList(),
      allergens:
          (json['allergens'] as List)?.map((e) => e as String)?.toList());
}

abstract class _$FoodItemSerializerMixin {
  String get name;
  List<String> get preferences;
  List<String> get allergens;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'preferences': preferences,
        'allergens': allergens
      };
}
