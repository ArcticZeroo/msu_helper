import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future makeRestRequest(String url, [Duration timeout = const Duration(seconds: 10)]) async {
  http.Response res;
  if (timeout != null) {
    res = await http.get(url).timeout(timeout);
  } else {
    res = await http.get(url);
  }

  if (!res.statusCode.toString().startsWith('2')) {
    throw new Exception('Request to $url unsuccessful: ${res.statusCode}');
  }

  if (res.body.length == 0) {
    throw new Exception('Empty response.');
  }

  dynamic decoded = json.decode(res.body);

  if (decoded == null) {
    throw new Exception('Empty JSON response.');
  }

  if (decoded is Map) {
    if ((decoded as Map<String, dynamic>).containsKey('error')) {
      throw new Exception('Request returned an error: ${decoded['error']}');
    }
  }

  return decoded;
}