import '../util/TextUtil.dart';
import '../config/Pages.dart';
import './request.dart';

class FoodTruckStop {
  final String location;
  final bool isCancelled;
  final DateTime start;
  final DateTime end;

  FoodTruckStop(Map<String, dynamic> jsonObject)
    : this.location = jsonObject['place'],
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
        str += 'has been cancelled.';
        continue;
      }

      str += 'is at ${stop.location} from ${stop.start.hour}:${stop.start.minute} to ${stop.end.hour}:${stop.end.minute}. ';
    }

    return str;
  }
}