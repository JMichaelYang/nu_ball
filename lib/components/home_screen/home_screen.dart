import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nu_ball/bloc/app_state_bloc.dart';
import 'package:nu_ball/bloc/count_bloc.dart';
import 'package:nu_ball/bloc/courts_bloc.dart';
import 'package:nu_ball/components/court_panel/court_panel.dart';
import 'package:nu_ball/court_list.dart';
import 'package:nu_ball/models/app_state_model.dart';
import 'package:nu_ball/models/count_data_model.dart';
import 'package:nu_ball/models/court_data_model.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocConsumer<AppStateBloc, AppStateModel>(
          listenWhen: (AppStateModel previous, AppStateModel current) => previous.date != current.date,
          listener: (BuildContext context, AppStateModel state) =>
              context.bloc<CourtsBloc>().add(state.formattedDateText),
          builder: _buildCourts,
        ),
      ),
    );
  }

  /// Builds the app bar for the home screen, which displays refresh and date change functionality.
  Widget _buildTopBar(ThemeData theme, BuildContext context, AppStateModel appState) {
    final AppStateBloc appStateBloc = context.bloc<AppStateBloc>();

    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildLeadingButton(context, appStateBloc, appState),
          Text(appState.dateText, style: theme.textTheme.title),
          _buildTrailingButton(appStateBloc),
        ],
      ),
    );
  }

  /// Builds a leading button, which refreshes the page or skips to the previous date depending on the context.
  Widget _buildLeadingButton(BuildContext context, AppStateBloc appStateBloc, AppStateModel appState) {
    final CourtsBloc courtsBloc = context.bloc<CourtsBloc>();
    final CountBloc countBloc = context.bloc<CountBloc>();

    void onRefresh() {
      courtsBloc.add(appState.formattedDateText);
      countBloc.add(true);
    }

    void onBack() {
      appStateBloc.add(AppStateEvent(AppStateEventTypes.PREVIOUS_DAY));
    }

    return IconButton(
      icon: Icon(appState.isToday ? Icons.refresh : Icons.arrow_back),
      onPressed: appState.isToday ? onRefresh : onBack,
    );
  }

  /// Builds a trailing button, which skips to the next date.
  Widget _buildTrailingButton(AppStateBloc appStateBloc) {
    return IconButton(
      icon: Icon(Icons.arrow_forward),
      onPressed: () => appStateBloc.add(AppStateEvent(AppStateEventTypes.NEXT_DAY)),
    );
  }

  /// Builds a widget that displays the current player count.
  Widget _buildCount(ThemeData theme) {
    // Renders a small progress indicator for use in the count row.
    Widget smallProgressIndicator() {
      return SizedBox(width: 10, height: 10, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    // Renders a player count widget.
    Widget buildPlayerCount(CountDataModel state) {
      String countText = state.isEmpty ? 'player count: ' : 'player count: ${state.count}';
      List<Widget> children = <Widget>[Text(countText)];
      if (state.isEmpty) children.add(smallProgressIndicator());

      return Expanded(flex: 0, child: Row(children: children));
    }

    // Creates a list of widgets for use in a count row.
    List<Widget> buildCount(CountDataModel state) {
      Widget updated = state.isEmpty ? smallProgressIndicator() : Text('${state.dateString}, ${state.timeString}');

      return <Widget>[
        buildPlayerCount(state),
        updated,
      ];
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 2, 12, 6),
      child: BlocBuilder<CountBloc, CountDataModel>(
        builder: (BuildContext context, CountDataModel state) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: buildCount(state),
        ),
      ),
    );
  }

  /// Builds a column of panels that display court data.
  Widget _buildPanels(int expanded) {
    Widget buildPanels(BuildContext context, List<CourtDataModel> state) {
      List<CourtDataModel> source = state.isEmpty
          ? courtList.map((Map court) => CourtDataModel.empty(court['displayName'], court['imagePath'])).toList()
          : state;

      List<Widget> panels = [];

      for (int i = 0; i < source.length; i++) {
        panels.add(CourtPanel(source[i], expanded, i));
      }

      return Column(
        children: panels,
        crossAxisAlignment: CrossAxisAlignment.stretch,
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: BlocBuilder<CourtsBloc, List<CourtDataModel>>(builder: buildPanels),
    );
  }

  /// Builds a listing of the courts with the appropriate data.
  Widget _buildCourts(BuildContext context, AppStateModel appState) {
    ThemeData theme = Theme.of(context);

    List<Widget> children = <Widget>[Expanded(flex: 0, child: _buildTopBar(theme, context, appState))];
    if (appState.isToday) children.addAll([Divider(), Expanded(flex: 0, child: _buildCount(theme))]);
    children.add(Expanded(flex: 1, child: _buildPanels(appState.expanded)));

    return Column(
      children: children,
    );
  }
}
