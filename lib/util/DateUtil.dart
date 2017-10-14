import 'package:intl/intl.dart';

class DateUtil {
  static toTimeString(DateTime from) {
    return new DateFormat.jm().format(from);
  }
}