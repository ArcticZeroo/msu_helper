import 'package:msu_helper/util/DateUtil.dart';

import '../util/TextUtil.dart';
import '../config/Pages.dart';
import './request.dart';

class FoodTruckStop {
  final String location;
  final String mapsLocation;
  final bool isCancelled;
  final DateTime start;
  final DateTime end;

  FoodTruckStop(Map<String, dynamic> jsonObject)
    : this.location = jsonObject['place'],
      this.mapsLocation = (jsonObject['place'].toString().contains(' near ') ? jsonObject['place'].toString().split(' near ')[1].trim() : jsonObject['place']),
      this.isCancelled = jsonObject['place'].toLowerCase().contains('cancelled'),
      this.start = new DateTime.fromMillisecondsSinceEpoch(jsonObject['start']),
      this.end = new DateTime.fromMillisecondsSinceEpoch(jsonObject['end']);
}

class FoodTruckResponse {
  List<FoodTruckStop> stops;

  FoodTruckResponse(this.stops);

  static FoodTruckResponse cached;

  static make([bool refresh = false]) async {
    if (!refresh && FoodTruckResponse.cached != null) {
      return cached;
    }

    Map<String, dynamic> jsonObject = await makeRestRequest(Pages.getUrl(Pages.FOOD_TRUCK));

    List<FoodTruckStop> stops = new List();

    for (Map<String, dynamic> entry in jsonObject['stops']) {
      stops.add(new FoodTruckStop(entry));
    }

    FoodTruckResponse.cached = new FoodTruckResponse(stops);

    return FoodTruckResponse.cached;
  }

  toString() {
    String str = 'The food truck has ${this.stops.length} stop${this.stops.length == 1 ? '' : 's'}. ';

    for (int i = 0; i < this.stops.length; i++) {
      FoodTruckStop stop = this.stops[i];

      str += 'The ${TextUtil.prettifyNum(i + 1)} stop ';

      if (stop.isCancelled) {
        str += 'has been cancelled. ';
        continue;
      }

      if (stop.end.isBefore(new DateTime.now())) {
        str += 'was at ${stop.location}, but left at ${DateUtil.toTimeString(stop.end)}. ';
        continue;
      }

      str += 'is at ${stop.location} from ${DateUtil.toTimeString(stop.start)} to ${DateUtil.toTimeString(stop.end)}. ';
    }

    return str;
  }
}