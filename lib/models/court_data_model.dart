import 'package:nu_ball/models/event_data_model.dart';

/// A representation of all of the events happening on a court on a certain day.
class CourtDataModel {
  final DateTime date;
  final String displayName;
  final String imagePath;
  final List<EventDataModel> _events;

  /// Converts a list of event maps into a [CourtDataModel].
  CourtDataModel.fromList(String stringDate, this.displayName, this.imagePath, List<Map> list)
      : date = DateTime.parse(stringDate),
        _events = list
            ?.map((Map map) => EventDataModel.fromJson(map))
            ?.where((EventDataModel model) => isSameDay(stringDate, model))
            ?.toList() {
    if (_events == null) throw ArgumentError('A court data model received a null map list');
  }

  /// Creates an empty court data model.
  CourtDataModel.empty(this.displayName, this.imagePath)
      : this.date = null,
        this._events = null;

  /// Checks whether the event represented by the passed [EventDataModel] occurs on the same day at the date represented
  /// by [date].
  static bool isSameDay(String date, EventDataModel model) {
    // Create a date for the last possible time that an event could end at.
    DateTime endTime = DateTime.parse(date).add(Duration(days: 1, hours: 1, minutes: 1));
    return model.end.isBefore(endTime);
  }

  /// A getter for determining if a [CourtDataModel] is empty.
  bool get isEmpty => _events == null;

  /// A getter for the events that only provides events that end after the current time.
  List<EventDataModel> get events =>
      this._events?.where((EventDataModel model) => DateTime.now().isBefore(model.end))?.toList();
}
