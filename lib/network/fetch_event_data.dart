import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:nu_ball/network/utils.dart';

// The URL to POST to in order to receive event information.
const String _POST_URL = 'https://nuevents.neu.edu/ServerApi.aspx/CustomBrowseEvents';

/// Builds an appropriate request body using the provided information.
String _buildRequestBody(String date, int roomId) {
  Map body = {
    'date': date + ' 00:00:00',
    'data': {
      'BuildingId': -1,
      'GroupTypeId': -1,
      'GroupId': -1,
      'EventTypeId': -1,
      'RoomId': roomId,
      'StatusId': -1,
      'ZeroDisplayOnWeb': 1,
      'HeaderUrl': '',
      'Format': 0,
      'Rollup': 0,
      'PageSize': 50,
      'DropEventsInPast': false
    },
  };

  return jsonEncode(body);
}

/// Adds the appropriate headers to an event request.
void _buildRequestHeaders(HttpClientRequest request, String body) {
  request.headers.set('Accept', 'application/json, text/javascript, */*; q=0.01');
  request.headers.set('Accept-Encoding', 'gzip, deflate, br');
  request.headers.set('Accept-Language', 'en-US;q=0.8,en;q=0.7');
  request.headers.persistentConnection = true;
  request.headers.contentLength = body.length;
  request.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
  request.headers.host = 'nuevents.neu.edu';
}

/// Fetches court event data and returns it as a [List] of daily booking results. The request must be
/// parameterized by a [date] in the 'YYYY-MM-DD' format, and an integer [roomId].
Future<List<Map>> fetchEventData(String date, int roomId, Function onError) {
  if (date == null || date.isEmpty || date.length != 10)
    throw ArgumentError('A court data fetch must have a valid date parameter of the format: \'YYYY-MM-DD\'');
  if (roomId == null || roomId < 0)
    throw ArgumentError('A court data fetch must have a valid room ID parameter greater than 0');

  Completer<List<Map>> completer = Completer();
  String body = _buildRequestBody(date, roomId);

  HttpClient().postUrl(Uri.parse(_POST_URL)).then((HttpClientRequest request) {
    _buildRequestHeaders(request, body);
    request.write(body);
    return request.close();
  }).then((HttpClientResponse response) async {
    // Read the raw response from the server.
    String rawResponse = await readResponse(response);
    Map jsonResponse = jsonDecode(rawResponse);

    // Extract the data field from the raw response.
    String rawData = jsonResponse['d'];
    rawData.replaceAll('\\"', '"');
    Map jsonData = jsonDecode(rawData);

    // Complete the future.
    completer.complete(List<Map>.from(jsonData['DailyBookingResults']));
  }).catchError(onError);

  return completer.future;
}
