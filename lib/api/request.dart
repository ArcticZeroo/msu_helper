import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future toUTF8(HttpClientResponse res) async {
  Stream stream = res.transform(UTF8.decoder);

  String responseText = "";

  await for (var str in stream) {
    responseText += str;
  }

  print(responseText);

  return responseText;
}

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

  dynamic decoded = new JsonDecoder().convert(res.body);

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