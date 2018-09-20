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

  @override
  bool operator ==(other) {
    if (other is FoodItem) {
      return other.name.toLowerCase() == name.toLowerCase();
    }

    return false;
  }

  @override
  int get hashCode => name.hashCode;
}