import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Reads the response from an HTTP request into a single, parseable string.
Future<String> readResponse(HttpClientResponse response) async {
  Completer<String> completer = Completer();
  StringBuffer contents = StringBuffer();

  // Listen to the response stream until we receive a done signal, then return the response.
  response.transform(utf8.decoder).listen((String data) {
    contents.write(data);
  }, onDone: () {
    completer.complete(contents.toString());
  });

  return completer.future;
}
