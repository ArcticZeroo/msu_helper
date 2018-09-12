import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_venue.dart';
import 'package:msu_helper/api/dining_hall/structures/food_item.dart';
import 'package:msu_helper/api/reloadable.dart';
import 'package:msu_helper/config/settings_config.dart';
import 'package:msu_helper/pages/dining_hall/dining_hall_page.dart';
import 'package:msu_helper/pages/settings_page.dart';
import 'package:msu_helper/util/TextUtil.dart';
import 'package:msu_helper/widgets/collapsible/collapsible_card.dart';
import 'package:msu_helper/widgets/dining_hall/menu/menu_display_controller.dart';
import 'package:msu_helper/widgets/material_card.dart';
import 'package:msu_helper/widgets/wrappable_widget.dart';
import '../../../api/settings/provider.dart' as settingsProvider;

class VenueDisplay extends StatefulWidget {
  final DiningHallVenue venue;

  VenueDisplay(this.venue);

  @override
  State<StatefulWidget> createState() => new VenueDisplayState();
}

class VenueDisplayState extends Reloadable<VenueDisplay> {
  CollapsibleCard collapsibleCard;
  bool collapsed;

  VenueDisplayState() : super([SettingsPage.reloadableCategory]);

  List<Widget> getTitleChildren() {
    List<Widget> children = [
      new Text(widget.venue.name.split(' ').map(TextUtil.capitalize).join(' '), style: MaterialCard.titleStyle)
    ];

    if (widget.venue.description != null && settingsProvider.getCached(SettingsConfig.showVenueDescriptions)) {
      children.add(new Text(widget.venue.description, style: MaterialCard.subtitleStyle));
    }

    return children;
  }

  Widget buildFoodItem(FoodItem foodItem) {
    return new ListTile(
      title: new Text(foodItem.name),
      subtitle: foodItem.allergens.length == 0 ? null : new Text('Contains: ${foodItem.allergens.join(', ')}'),
      trailing: new Row(
        mainAxisSize: MainAxisSize.min,
        children: foodItem.preferences.map((a) => new Container(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: new CircleAvatar(
            backgroundImage: new AssetImage('assets/dining/${a.toLowerCase().split(' ').join('_')}.png'),
            maxRadius: 12.0,
          ),
        )).toList(),
      ),
    );
  }

  Widget buildMenu() {
    return new Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: new Column(
          children: widget.venue.menu.map(buildFoodItem).toList(),
        )
    );
  }

  @override
  void initState() {
    super.initState();
    print('Venue should start as collapsed=${MenuDisplayControllerWidget.isVenueCollapsed(widget.venue)}');
    collapsibleCard = new CollapsibleCard(
      title: new WrappableWidget(
          new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getTitleChildren()
          )
      ),
      body: buildMenu(),
      initial: MenuDisplayControllerWidget.isVenueCollapsed(widget.venue),
    );

    collapsibleCard.isCollapsed.addListener(() {
      bool shouldBeCollapsed = collapsibleCard.isCollapsed.value;

      MenuDisplayControllerWidget.setVenueCollapsed(widget.venue, shouldBeCollapsed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: collapsibleCard
    );
  }
}