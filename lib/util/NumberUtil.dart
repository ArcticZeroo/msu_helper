class NumberUtil {
  static int round(double i, [int nearest = 1]) {
    return (i / nearest).round() * nearest;
  }
}