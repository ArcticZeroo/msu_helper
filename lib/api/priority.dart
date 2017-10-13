import 'dart:math' as math;
import 'package:meta/meta.dart';

int hourRaise = 360;
int subtractDivisor = 18;
int primaryPow = 50;
int secondaryPow = 6;

double computePriority({
  @required double base,
  @required DateTime when,
  double mult = 3.0
}) {

  int timeUntil =  ((when.millisecondsSinceEpoch - new DateTime.now().millisecondsSinceEpoch) / (1000 * 60 * 60)).floor();

  // https://www.desmos.com/calculator/buesvqfd64
  return (base * mult)*((hourRaise - timeUntil) / hourRaise) + math.min((
    math.pow(primaryPow, -((hourRaise*timeUntil) - 1))
    - math.pow(secondaryPow, -(((hourRaise/subtractDivisor)*timeUntil) - 1))
  ), 0);
}