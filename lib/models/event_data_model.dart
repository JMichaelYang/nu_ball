// A set of keys for use in parsing event information.
import 'package:intl/intl.dart';

const String _NAME_KEY = 'EventName';
const String _START_KEY = 'GmtStart';
const String _END_KEY = 'GmtEnd';

/// A representation of an event happening on a court.
class EventDataModel {
  final String name;
  final DateTime start;
  final DateTime end;

  /// Converts the JSON representation of a court event into an [EventDataModel].
  EventDataModel.fromJson(Map json)
      : name = json[_NAME_KEY]?.replaceAll('&#39;', '\''),
        start = DateTime.parse(json[_START_KEY]).subtract(Duration(hours: 5)),
        end = DateTime.parse(json[_END_KEY]).subtract(Duration(hours: 5)) {
    if (name == null || name.isEmpty) throw ArgumentError('A court event must have a valid name, received $name');
  }

  /// Getters for the start and end time objects for this event.
  String get startString => DateFormat('h:mm a').format(start);
  String get endString => DateFormat('h:mm a').format(end);
}
