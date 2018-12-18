import 'package:flutter/material.dart';

import 'package:msu_helper/api/food_truck/provider.dart' as foodTruckProvider;
import 'package:msu_helper/api/food_truck/structures/menu/food_truck_menu.dart';
import 'package:msu_helper/widgets/error_card.dart';
import 'package:msu_helper/widgets/food_truck/single_menu_display.dart';
import 'package:msu_helper/widgets/loading_widget.dart';

class FoodTruckMenuDisplay extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return new FutureBuilder<List<FoodTruckMenu>>(
            future: foodTruckProvider.retrieveMenus(),
            builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                    return LoadingWidget(name: 'menus');
                }

                if (snapshot.hasError) {
                    return ErrorCardWidget('Could not load food truck menus');
                }

                if (snapshot.data.isEmpty) {
                    return ErrorCardWidget('Menus have not been posted');
                }

                return Column(
                    children: snapshot.data.map((menu) => SingleMenuDisplay(menu)).toList(),
                );
            },
        );
    }
}