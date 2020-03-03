import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nu_ball/bloc/app_state_bloc.dart';
import 'package:nu_ball/models/court_data_model.dart';
import 'package:nu_ball/models/event_data_model.dart';

/// A panel that displays the status of a court.
class CourtPanel extends StatelessWidget {
  final CourtDataModel _model;
  final int _expanded;
  final int _index;

  CourtPanel(this._model, this._expanded, this._index);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Expanded(
      flex: _expanded == _index ? 2 : 1,
      child: Card(
        child: Stack(
          children: <Widget>[
            _buildShader(theme),
            _buildBody(context, theme),
          ],
        ),
        margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  /// Generates the body of the court panel.
  Widget _buildBody(BuildContext context, ThemeData theme) {
    if (_model.isEmpty) return Center(child: CircularProgressIndicator());

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTitleRow(context, theme),
          _buildEvent(theme, 0, 'Now: '),
          _buildEvent(theme, 1, 'Next: '),
        ],
      ),
    );
  }

  /// Builds an event listing for a court panel.
  Widget _buildEvent(ThemeData theme, int index, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.title),
        _buildEventText(theme, index),
      ],
    );
  }

  // Builds a widget that displays data regarding an event's timing.
  Widget _buildEventText(ThemeData theme, int index) {
    // If there is no event at this index, indicate that to the user.
    if (_model.events.length <= index) return Text('N/A', style: theme.textTheme.title);

    final EventDataModel event = _model.events[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          event.name,
          style: theme.textTheme.title,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${event.startString} - ${event.endString}',
          style: theme.textTheme.subhead,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Builds a title row that display's the court's name as a well as a widget to expand the panel.
  Widget _buildTitleRow(BuildContext context, ThemeData theme) {
    final AppStateBloc appStateBloc = context.bloc<AppStateBloc>();
    Function expand = () => appStateBloc.add(AppStateEvent(AppStateEventTypes.EXPAND, data: {'expanded': _index}));
    Function collapse = () => appStateBloc.add(AppStateEvent(AppStateEventTypes.EXPAND, data: {'expanded': -1}));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          _model.displayName,
          style: theme.textTheme.headline,
        ),
        IconButton(
          icon: Icon(_expanded == _index ? Icons.expand_less : Icons.expand_more),
          onPressed: _expanded == _index ? collapse : expand,
        ),
      ],
    );
  }

  /// Builds a shader that displays a gradient shaded image.
  Widget _buildShader(ThemeData theme) {
    Color colorbase = theme.brightness == Brightness.dark ? Colors.black : Colors.white;
    Color colorStart = colorbase.withOpacity(0.6);
    Color colorEnd = colorbase.withOpacity(0.8);

    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colorStart, colorEnd],
      ).createShader(Rect.fromLTRB(0, 0, 0, rect.height)),
      blendMode: theme.brightness == Brightness.dark ? BlendMode.darken : BlendMode.lighten,
      child: Container(
        decoration: _buildBackgroundImage(),
      ),
    );
  }

  /// Builds the appropriate background image for this court.
  Decoration _buildBackgroundImage() {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(_model.imagePath),
        fit: BoxFit.cover,
      ),
    );
  }
}
