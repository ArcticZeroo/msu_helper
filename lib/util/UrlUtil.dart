import 'package:url_launcher/url_launcher.dart';

class UrlUtil {
  static open(String url, [String backup]) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (backup != null) {
        return open(backup);
      } else {
        throw 'Could not open url $url';
      }
    }
  }

  static openMaps(urlEnding) {
    return open('https://maps.google.com/$urlEnding');
  }

  static openMapsToLocation(loc) {
    return openMaps('?q=$loc');
  }

  static openMapsToCoordinates(double x, double y) {
    return openMaps('?q=$x,$y');
  }
}