import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  HttpClient client = new HttpClient();

  HttpClientRequest req;
  try {
    req = (await client.getUrl(Uri.parse(url)));
  } catch (e) {
    return new Future.error(e);
  }

  HttpClientResponse res;
  try {
    res = await req.close();
  } catch (e) {
    return new Future.error(e);
  }

  String responseText;
  try {
    responseText = await toUTF8(res);
  } catch (e) {
    return new Future.error(e);
  }

  Map decoded = JSON.decode(responseText);

  if (!res.statusCode.toString().startsWith('2')) {
    return new Future.error('Request unsuccessful: ${decoded.containsKey('error') ? '(${res.statusCode}) ${decoded['error']}' : res.statusCode}');
  }

  if (decoded.containsKey('error')) {
    return new Future.error('Request returned an error: ${decoded['error']}');
  }

  return decoded;
}