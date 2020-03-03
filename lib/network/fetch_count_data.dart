import 'dart:async';
import 'dart:io';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:nu_ball/models/count_data_model.dart';
import 'package:nu_ball/network/utils.dart';

// The URL to GET to in order to receive count information.
const String _GET_URL = 'www.connect2concepts.com';
const String _GET_PATH = '/connect2';
const String _GET_TYPE = 'circle';
const String _GET_KEY = '2A2BE0D8-DF10-4A48-BEDD-B3BC0CD628E7';

/// Builds a URI populated with query params to use for a GET request.
Uri _buildCountUri() {
  const Map<String, String> queryParams = {
    'type': _GET_TYPE,
    'key': _GET_KEY,
  };

  return Uri.https(_GET_URL, _GET_PATH, queryParams);
}

/// Fetches court body count data.
Future<CountDataModel> fetchCountData(Function onError) async {
  Completer<CountDataModel> completer = Completer();

  HttpClient().getUrl(_buildCountUri()).then((HttpClientRequest request) {
    return request.close();
  }).then((HttpClientResponse response) async {
    String raw = await readResponse(response);
    Document parsed = parse(raw);

    // Retreive the inner HTML for the section that reports the court's count.
    String countHtml = parsed.getElementsByTagName('center')[11].children[1].innerHtml;
    if (!countHtml.contains('(Court)')) throw FormatException('Fetch count received a malformed HTML page.');
    List<String> elements = countHtml.split('Count: ')[1].split('<br>Updated: ');

    // Retreive the actual count.
    int count = int.parse(elements[0]);

    // Convert the date string into a parseable string.
    List<String> parts = elements[1].split(' ');
    List<String> dateParts = parts[0].split('/');

    String time;
    if (parts[2] == 'AM') {
      time = parts[1].length == 5 ? parts[1] : '0${parts[1]}';
    } else {
      List<String> timeParts = parts[1].split(':');
      int hour = int.parse(timeParts[0]);
      if (hour < 12) hour += 12;
      time = '$hour:${timeParts[1]}';
    }

    String formatted = '${dateParts[2]}-${dateParts[0]}-${dateParts[1]}T$time';
    completer.complete(CountDataModel(formatted, count));
  }).catchError(onError);

  return completer.future;
}
