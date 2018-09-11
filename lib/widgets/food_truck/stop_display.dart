import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_helper/api/food_truck/structures/food_truck_stop.dart';
import 'package:msu_helper/util/DateUtil.dart';
import 'package:msu_helper/util/TextUtil.dart';
import 'package:msu_helper/widgets/material_card.dart';
import 'package:msu_helper/widgets/wrappable_widget.dart';

class _AdditionalInfoData {
  final IconData icon;
  final Color color;
  final String text;
  final bool flipColor;

  _AdditionalInfoData({
    this.icon,
    this.text,
    this.color,
    this.flipColor = true
  });
}

class StopDisplay extends StatelessWidget {
  final FoodTruckStop stop;

  StopDisplay(this.stop);

  Widget getIconRow(IconData icon, String text, {Color iconColor = Colors.black54, Color textColor}) {
    TextStyle textStyle = textColor == null
        ? MaterialCard.subtitleStyle
        : MaterialCard.subtitleStyle.copyWith(color: textColor);

    return new Row(children: <Widget>[
      new Container(
        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 12.0, left: 8.0),
        child: new Icon(icon, color: iconColor),
      ),
      new WrappableWidget(new Text(text, style: textStyle))
    ]);
  }

  @override
  Widget build(BuildContext context) {
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

    _AdditionalInfoData additionalInfoData = null;
    if (stop.isCancelled) {
      additionalInfoData = new _AdditionalInfoData(
          icon: Icons.mood_bad,
          text: 'This stop has been cancelled',
          color: Colors.blue[800]
      );
    } else {
      if (stop.isToday) {
        DateTime now = DateTime.now();

        // Check if this stop has passed first so we can add the maps button in else
        if (stop.endDate.isBefore(now) || stop.endDate.isAtSameMomentAs(now)) {
          additionalInfoData = new _AdditionalInfoData(
              icon: Icons.mood_bad,
              text: 'This stop has already passed',
              color: Colors.grey[800]
          );
        } else {
          // Check if start <= now < end
          if (stop.isNow) {
            additionalInfoData = new _AdditionalInfoData(
                icon: Icons.timer,
                text: 'It is currently here, and will leave in ${DateUtil.formatDifference(stop.endDate.difference(now))}',
                color: Colors.green[800]
            );
            // Otherwise, since we know now is not after the end, it must be coming later than now
          } else {
            additionalInfoData = new _AdditionalInfoData(
                icon: Icons.timer,
                text: 'It will be here in ${DateUtil.formatDifference(stop.startDate.difference(now))}',
                color: Colors.amber[800]
            );
          }
        }
      }
    }

    List<Widget> columnChildren = [
      new Container(
          padding: const EdgeInsets.all(12.0),
          child: new Column(
            children: lines,
          )
      )
    ];

    if (additionalInfoData != null) {
      Color color = additionalInfoData.flipColor ? Colors.white : Colors.black54;

      columnChildren.add(
          new Container(
            decoration: BoxDecoration(color: additionalInfoData.color),
            padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0, right: 4.0),
            child: getIconRow(
                additionalInfoData.icon,
                additionalInfoData.text,
                iconColor: color,
                textColor: color
            ),
          )
      );
    }

    return new Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
        child: new MaterialCard(
          cardPadding: const EdgeInsets.all(0.0),
          bodyPadding: const EdgeInsets.all(0.0),
          body: new Column(
            children: columnChildren,
          ),
          onTap: stop.openMaps,
        )
    );
  }
}