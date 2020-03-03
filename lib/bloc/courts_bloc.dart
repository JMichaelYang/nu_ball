import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nu_ball/court_list.dart';
import 'package:nu_ball/models/court_data_model.dart';
import 'package:nu_ball/network/fetch_event_data.dart';

class CourtsBloc extends Bloc<String, List<CourtDataModel>> {
  final Function _onError;
  final Map<String, List<CourtDataModel>> _cache;

  CourtsBloc(this._onError) : this._cache = {};

  @override
  List<CourtDataModel> get initialState => [];

  @override
  Stream<List<CourtDataModel>> mapEventToState(String date) async* {
    if (date == null || date.isEmpty || date.length != 10)
      throw ArgumentError('A courts bloc event must be a date string formatted as \'YYYY-MM-DD\', received $date');

    if (_cache.containsKey(date)) {
      yield _cache[date];
    } else {
      yield [];

      // Error handling for the HTTP request.
      Function onError(error) {
        throw HttpException('Courts fetch failed: $error');
      }

      List<CourtDataModel> models = await Future.wait(courtList.map((Map court) {
        Completer<CourtDataModel> completer = Completer();

        fetchEventData(date, court['roomId'], onError).then((List<Map> map) {
          completer.complete(CourtDataModel.fromList(date, court['displayName'], court['imagePath'], map));
        });

        return completer.future;
      }));

      _cache[date] = models;
      yield models;
    }
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    _onError(error, stacktrace);
    super.onError(error, stacktrace);
  }
}
