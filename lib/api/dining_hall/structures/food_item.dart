import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part './food_item.g.dart';

@JsonSerializable()
class FoodItem extends Object with _$FoodItemSerializerMixin {
  FoodItem({
    this.name, this.preferences, this.allergens
  });

  final String name;
  final List<String> preferences;
  final List<String> allergens;

  factory FoodItem.fromJson(Map<String, dynamic> json) => _$FoodItemFromJson(json);
}