import 'dart:async';
import 'dart:core';

class TimedCacheEntry<T> {
  T value;
  int added;

  TimedCacheEntry(this.value) {
    added = DateTime.now().millisecondsSinceEpoch;
  }

  bool isValid(int expireTime) {
    return (DateTime.now().millisecondsSinceEpoch - added) >= expireTime;
  }

  void update(T value) {
    this.value = value;
    added = DateTime.now().millisecondsSinceEpoch;
  }
}

class TimedCache<K, V> {
  final int expireTime;
  final Future<V> Function(K) _fetch;
  Map<K, TimedCacheEntry<V>> _cache;

  TimedCache(this._fetch, [this.expireTime = 15*60*1000]) {
    _cache = new Map();
  }

  void put(K key, V value) {
    _cache[key] = new TimedCacheEntry<V>(value);
  }

  Future<V> get(K key) async {
    if (!_cache.containsKey(key)) {
      return null;
    }

    TimedCacheEntry entry = _cache[key];

    if (entry.isValid(expireTime)) {
      return entry.value;
    }

    V value = await _fetch(key);

    entry.update(value);

    return value;
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