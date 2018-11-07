import 'package:url_launcher/url_launcher.dart';

class UrlUtil {
  static openUrl(String url, [String backup]) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (backup != null) {
        return openUrl(backup);
      } else {
        throw 'Could not open url $url';
      }
    }
  }

  static openMapsCustom(urlEnding) {
    return openUrl('https://maps.google.com/?q=$urlEnding');
  }

  static openMapsToLocation(loc) {
    return openMapsCustom(loc);
  }

  static openMapsToCoordinates(double x, double y) {
    return openMapsCustom('$x,$y');
  }
}