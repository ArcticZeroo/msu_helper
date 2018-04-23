class ExpireTime {
  static const int DEFAULT = 30*60*1000;
  static const int DINING_HALL_MENU = 24*60*60*1000;

  static int getLastTime(int expireTime) {
    return DateTime.now().millisecondsSinceEpoch - expireTime;
  }

  static bool isValid(int retrieveTime, int expireTime) {
    return DateTime.now().millisecondsSinceEpoch - retrieveTime < expireTime;
  }
}