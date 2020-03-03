import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nu_ball/models/app_state_model.dart';

/// An enumeration of the types of events that can be passed to the app state bloc.
enum AppStateEventTypes {
  NEXT_DAY,
  PREVIOUS_DAY,
  EXPAND,
}

/// An event that can be passed to the app state bloc in order to update state.
class AppStateEvent {
  final AppStateEventTypes type;
  final Map data;

  AppStateEvent(this.type, {Map data}) : data = data;
}

class AppStateBloc extends Bloc<AppStateEvent, AppStateModel> {
  AppStateBloc();

  @override
  AppStateModel get initialState => AppStateModel.initial();

  @override
  Stream<AppStateModel> mapEventToState(AppStateEvent event) async* {
    switch (event.type) {
      case AppStateEventTypes.NEXT_DAY:
        yield state.nextDay;
        break;
      case AppStateEventTypes.PREVIOUS_DAY:
        yield state.previousDay;
        break;
      case AppStateEventTypes.EXPAND:
        yield AppStateModel.copyWith(state, expanded: event.data['expanded']);
        break;
      default:
        throw new ArgumentError('An invalid type of app state event was passed');
    }
  }

  void _handleStateError(Object error, StackTrace stacktrace) {
    print('app state error: $error');
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    _handleStateError(error, stacktrace);
    super.onError(error, stacktrace);
  }
}
