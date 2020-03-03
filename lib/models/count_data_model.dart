import 'package:intl/intl.dart';

/// A representation of the count of people on the courts at a certain time.
class CountDataModel {
  final DateTime date;
  final int count;

  /// Creates an empty count data model.
  CountDataModel.empty()
      : date = null,
        count = null;

  /// Creates a model representing a single count.
  CountDataModel(String stringDate, this.count) : date = DateTime.parse(stringDate) {
    if (this.count == null || this.count < 0)
      throw ArgumentError('A count data model requires a valid count, received ${this.count}');
  }

  /// Getter for whether this model is empty.
  bool get isEmpty => this.date == null;

  /// Getters for the time and date of this count.
  String get dateString => DateFormat('MMMM d').format(date);
  String get timeString => DateFormat('h:mm a').format(date);
}
