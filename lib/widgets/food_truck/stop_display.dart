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
  final bool flipTextColor;

  _AdditionalInfoData({
    this.icon,
    this.text,
    this.color,
    this.flipTextColor = true
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
        padding: const EdgeInsets.all(4.0),
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
        color:
      )
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
}