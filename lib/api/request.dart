import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future makeRestRequest(String url) async {
  http.Response res;
  try {
    res = await http.get(url);
  } catch (e) {
    return new Future.error(e);
  }

  if (!res.statusCode.toString().startsWith('2')) {
    return new Future.error('Request unsuccessful: ${res.statusCode}');
  }

  if (res.body.length == 0) {
    return new Future.error('Empty response.');
  }

  dynamic decoded = json.decode(res.body);

  if (decoded == null) {
    return new Future.error('Empty JSON response.');
  }

  if (decoded is Map) {
    if ((decoded as Map<String, dynamic>).containsKey('error')) {
      return new Future.error('Request returned an error: ${decoded['error']}');
    }
  }

  return decoded;
}