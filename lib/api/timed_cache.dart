import 'dart:async';
import 'dart:core';

import 'package:msu_helper/config/expire_time.dart';

class TimedCacheEntry<T> {
  T value;
  int added;
  int expireTime;

  TimedCacheEntry(this.value, {
    int added,
    this.expireTime = ExpireTime.THIRTY_MINUTES
  }) {
    this.added = added ?? DateTime.now().millisecondsSinceEpoch;
  }

  bool isValid([int expireTime]) {
    if (expireTime == null) {
      expireTime = this.expireTime;
    }

    return ExpireTime.isValid(added, expireTime);
  }

  void update(T value) {
    this.value = value;
    added = DateTime.now().millisecondsSinceEpoch;
  }
}

class TimedCache<K, V> {
  final int expireTime;
  final Future<dynamic> Function(K) _fetch;
  Map<K, TimedCacheEntry<V>> _cache;

  TimedCache(this._fetch, [this.expireTime = 15*60*1000]) {
    _cache = new Map();
  }

  void put(K key, V value, {int added}) {
    _cache[key] = new TimedCacheEntry<V>(value, added: added);
  }

  TimedCacheEntry<V> getDirectEntry(K key) {
    if (!_cache.containsKey(key)) {
      return null;
    }

    return _cache[key];
  }

  Future<V> get(K key) async {
    TimedCacheEntry entry;
    if (_cache.containsKey(key)) {
      entry = _cache[key];

      if (entry.isValid(expireTime)) {
        return entry.value;
      }
    }

    var fetched = await _fetch(key);

    if (fetched is TimedCacheEntry<V>) {
      _cache[key] = fetched;
      return fetched.value;
    } else if (fetched is V) {
      put(key, fetched);
    } else {
      throw new TypeError();
    }

    return fetched;
  }

  bool update(K key, V value) {
    if (!_cache.containsKey(key)) {
      return false;
    }

    _cache[key].update(value);
    return true;
  }

  bool hasValid(K key) {
    if (!_cache.containsKey(key)) {
      return false;
    }

    return _cache[key].isValid(expireTime);
  }
}