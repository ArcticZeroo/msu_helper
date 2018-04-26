class ExpireTime {
  static const int THIRTY_MINUTES = 30*60*1000;
  static const int DAY = 24*60*60*1000;

  static int getLastTime(int expireTime) {
    return DateTime.now().millisecondsSinceEpoch - expireTime;
  }

  static bool isValid(int retrieveTime, int expireTime) {
    return DateTime.now().millisecondsSinceEpoch - retrieveTime < expireTime;
  }
}