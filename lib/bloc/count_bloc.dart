import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nu_ball/models/count_data_model.dart';
import 'package:nu_ball/network/fetch_count_data.dart';

class CountBloc extends Bloc<bool, CountDataModel> {
  final Function _onError;

  CountBloc(this._onError);

  @override
  CountDataModel get initialState => CountDataModel.empty();

  @override
  Stream<CountDataModel> mapEventToState(bool event) async* {
    yield CountDataModel.empty();

    // Error handling for the HTTP request.
    Function onError(error) {
      throw HttpException('Count fetch failed: $error');
    }

    yield await fetchCountData(onError);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    _onError(error, stacktrace);
    super.onError(error, stacktrace);
  }
}
