import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_helper/api/food_truck/provider.dart' as foodTruckProvider;
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/TextUtil.dart';
import 'package:msu_helper/widgets/material_card.dart';
import 'package:msu_helper/widgets/wrappable_text.dart';

class FoodTruckPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new FoodTruckPageState();
}

class FoodTruckPageState extends State<FoodTruckPage> {
  List<FoodTruckStop> _stops;
  bool failed = false;

  @override
  void initState() {
    super.initState();

    load();
  }

  load() async {
    print('Loading food truck info for page...');
    try {
      _stops = (await foodTruckProvider.retrieveStops()) ?? [];
    } catch (e) {
      print('Could not load food truck stops:');
      print(e);
      setState(() {
        failed = true;
      });
      return;
    }

    setState(() {
      failed = false;
    });
  }

  Widget getIconRow(IconData icon, String text) {
    return new Row(children: <Widget>[
      new Container(
        padding: const EdgeInsets.all(4.0),
        child: new Icon(icon, color: Colors.black54),
      ),
      new WrappableWidget(
          new Text(text, style: MaterialCard.subtitleStyle)
      )
    ]);
  }

  Widget buildStop(FoodTruckStop stop) {
    List<Widget> lines = [];

    lines.add(
        getIconRow(Icons.location_on, stop.place)
    );

    lines.add(
        getIconRow(
            Icons.today,
            new DateFormat("EEEE, MMMM d'${TextUtil.getOrdinalSuffix(stop.startDate.day)}', y").format(stop.startDate)
        )
    );

    lines.add(
        getIconRow(
            Icons.access_time,
            '${DateUtil.toTimeString(stop.startDate)} - ${DateUtil.toTimeString(stop.endDate)}'
        )
    );

    print(stop);

    if (stop.isCancelled) {
      lines.add(getIconRow(Icons.mood_bad, 'This stop has been cancelled'));
    } else {
      if (stop.isToday) {
        DateTime now = DateTime.now();

        // Check if this stop has passed first so we can add the maps button in else
        if (stop.endDate.isBefore(now) || stop.endDate.isAtSameMomentAs(now)) {
          lines.add(getIconRow(Icons.mood_bad, 'This stop has already passed'));
        } else {
          // Check if start <= now < end
          if (stop.isNow) {
            lines.add(getIconRow(Icons.timer, 'It is currently here, and will leave in ${DateUtil.formatDifference(stop.endDate.difference(now))}'));
            // Otherwise, since we know now is not after the end, it must be coming later than now
          } else {
            lines.add(getIconRow(Icons.timer, 'It will be here in ${DateUtil.formatDifference(stop.startDate.difference(now))}'));
          }
        }
      }
    }

    /*if (stop.isCancelled) {
      lines.add('This stop has been cancelled');
    } else {
      String endTime = DateUtil.toTimeString(stop.endDate);

      if (stop.endDate.isBefore(DateTime.now())) {
        lines.add('The Food Truck left here at $endTime');
      } else {
        if (stop.isNow()) {
          lines.add('The Food Truck is currently here until $endTime');
        } else {
          lines.add('The Food Truck will be here from ${DateUtil.toTimeString(stop.startDate)} to $endTime');
        }
      }
    }*/

    return new Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
        child: new MaterialCard(
          body: new Column(
            children: lines,
          ),
          onTap: stop.openMaps,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (failed) {
      return new Center(
        child: new Text('Could not load food truck data.'),
      );
    }

    if (_stops == null) {
      return new Center(
        child: new Text('Loading stops...'),
      );
    }

    List<Widget> columnChildren = <Widget>[];

    if (_stops.length == 0) {
      return new Center(
          child: new Text('No stops found.',
          style: MaterialCard.subtitleStyle)
      );
    }

    DateTime now = DateTime.now();
    List<FoodTruckStop> today = _stops.where((stop) => stop.startDate.day == now.day && stop.startDate.month == now.month).toList();
    // Ignore old stops (ones from before today), we only want after today
    List<FoodTruckStop> notToday = _stops.where((stop) => !today.contains(stop) && stop.startDate.isAfter(now)).toList();

    if (today.isEmpty && notToday.isEmpty) {
      return new Center(
        child: new Text('All stops listed have passed.'),
      );
    }

    final TextStyle titleStyle = const TextStyle(
        fontSize: 24.0,
        color: Colors.black87,
        fontWeight: FontWeight.w500
    );

    if (today.length != 0) {
      columnChildren.add(new Container(
        padding: const EdgeInsets.all(8.0),
        child: new Center(child: new Text('Today', style: titleStyle)),
      ));
      columnChildren.addAll(today.map(buildStop));
    }

    if (notToday.length != 0) {
      columnChildren.add(new Container(
        padding: const EdgeInsets.all(8.0),
        child: new Center(child: new Text('Later This Week', style: titleStyle)),
      ));
      columnChildren.addAll(notToday.map(buildStop));
    }

    columnChildren[0] = new Container(
      padding: const EdgeInsets.only(top: 8.0),
      child: columnChildren.first,
    );

    return new Center(
      child: new Scrollbar(
          child: new RefreshIndicator(
              child: new ListView(
                scrollDirection: Axis.vertical,
                children: columnChildren,
                physics: const AlwaysScrollableScrollPhysics(),
              ),
              onRefresh: () async {
                try {
                  _stops = await foodTruckProvider.retrieveStopsFromWebAndSave();
                } catch (e) {
                  print('Could not refresh stops from web:');
                  print(e);
                }

                await load();
              })
      ),
    );
  }
}