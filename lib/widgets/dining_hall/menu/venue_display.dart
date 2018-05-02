import 'package:flutter/material.dart';
import 'package:msu_helper/api/dining_hall/structures/dining_hall_venue.dart';
import 'package:msu_helper/api/dining_hall/structures/food_item.dart';
import 'package:msu_helper/util/TextUtil.dart';
import 'package:msu_helper/widgets/material_card.dart';

class VenueDisplay extends StatefulWidget {
  final DiningHallVenue venue;

  VenueDisplay(this.venue);

  @override
  State<StatefulWidget> createState() => new VenueDisplayState();
}

class VenueDisplayState extends State<VenueDisplay> {
  Widget _menu;

  Widget buildTitle() {
    List<Widget> children = [];

    children.add(new Text(widget.venue.name.split(' ').map(TextUtil.capitalize).join(' '), style: MaterialCard.titleStyle));

    if (widget.venue.description != null) {
      children.add(new Text(widget.venue.description, style: MaterialCard.subtitleStyle));
    }

    return new Column(
      children: children,
    );
  }

  Widget buildMenu() {
    if (_menu != null) {
      return _menu;
    }

    List<Widget> children = [];

    for (FoodItem foodItem in widget.venue.menu) {
      children.add(new ListTile(
        title: new Text(foodItem.name),
        subtitle: foodItem.allergens.length == 0 ? null : new Text('Contains: ${foodItem.allergens.join(', ')}'),
        trailing: new Row(
          children: foodItem.preferences.map((a) => new CircleAvatar(
            backgroundImage: new AssetImage('assets/dining/${a.toLowerCase().split(' ').join('_')}.png'),
            maxRadius: 8.0,
          )).toList(),
        ),
      ));
    }

    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: new Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        buildTitle(),
        buildMenu()
      ]
    );
  }
}