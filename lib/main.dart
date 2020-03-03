import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nu_ball/bloc/app_state_bloc.dart';
import 'package:nu_ball/bloc/count_bloc.dart';
import 'package:nu_ball/bloc/courts_bloc.dart';
import 'package:nu_ball/components/home_screen/home_screen.dart';

import 'package:nu_ball/network/fetch_count_data.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocLayer();
  }
}

class BlocLayer extends StatefulWidget {
  BlocLayer() {
    fetchCountData((e) => {});
  }

  @override
  State<StatefulWidget> createState() => BlocLayerState();
}

class BlocLayerState extends State<BlocLayer> {
  AppStateBloc _appStateBloc;
  CourtsBloc _courtsBloc;
  CountBloc _countBloc;

  @override
  void initState() {
    // Bloc initialization.
    _appStateBloc = AppStateBloc();

    _courtsBloc = CourtsBloc(_handleCourtError);
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _courtsBloc.add(date);

    _countBloc = CountBloc(_handleCountError);
    _countBloc.add(true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NU Ball',
      theme: ThemeData.dark().copyWith(primaryColor: Colors.deepPurple),
      home: _wrapScreen(HomeScreen()),
    );
  }

  Widget _wrapScreen(Widget child) {
    return MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<AppStateBloc>(create: (BuildContext context) => _appStateBloc),
        BlocProvider<CourtsBloc>(create: (BuildContext context) => _courtsBloc),
        BlocProvider<CountBloc>(create: (BuildContext context) => _countBloc),
      ],
      child: child,
    );
  }

  void _handleCourtError(Object error, StackTrace trace) {
    // TODO: Pass an error to the app state bloc.
    print('court error: $error');
  }

  void _handleCountError(Object error, StackTrace trace) {
    // TODO: Pass an error to the app state bloc.
    print('count error: $error');
  }
}
