import 'package:flutter/material.dart';
import 'package:msu_helper/api/food_truck/structures/menu/food_truck_menu.dart';
import 'package:msu_helper/api/food_truck/structures/menu/food_truck_menu_item.dart';
import 'package:msu_helper/util/TextUtil.dart';
import 'package:msu_helper/widgets/collapsible/collapsible_card.dart';
import 'package:msu_helper/widgets/material_card.dart';

class SingleMenuDisplay extends StatelessWidget {
  final FoodTruckMenu menu;

  SingleMenuDisplay(this.menu);

  static String _formatPrice(double price) {
    if (price == price.floor()) {
      // Truncate if possible
      return '\$${price.floor()}';
    }

    return '\$${price.toStringAsFixed(2)}';
  }

  static Widget _buildMenuItem(FoodTruckMenuItem item) {
    return ListTile(
      title: new Text(item.name),
      subtitle: new Text(item.description),
      trailing: new Text(_formatPrice(item.price)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CollapsibleCard(
      title: new Text(TextUtil.capitalize(menu.title), style: MaterialCard.titleStyle),
      body: Column(
        children: menu.items.map(_buildMenuItem).toList(),
      ),
    );
  }
}