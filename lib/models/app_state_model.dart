import 'package:intl/intl.dart';

/// A representation of the current state of the app.
class AppStateModel {
  final DateTime date;
  final int expanded;

  /// Creates a new [AppStateModel] with default values.
  AppStateModel.initial()
      : date = DateTime.now(),
        expanded = -1;

  /// Copies an [AppStateModel] with the given updates.
  AppStateModel.copyWith(AppStateModel source, {int expanded})
      : date = source.date,
        expanded = expanded ?? source.expanded;

  /// Creates a new [AppStateModel] with the provided values.
  AppStateModel._internal(this.date, this.expanded);

  // Model related getters.
  AppStateModel get nextDay => AppStateModel._internal(date.add(Duration(days: 1)), expanded);

  AppStateModel get previousDay => AppStateModel._internal(date.subtract(Duration(days: 1)), expanded);

  // Date related getters.
  bool get isToday {
    DateTime now = DateTime.now();
    return now.day == date.day && now.month == date.month && now.year == date.year;
  }

  String get dateText => DateFormat.yMMMMd().format(date);

  String get formattedDateText => DateFormat('yyyy-MM-dd').format(date);
}
