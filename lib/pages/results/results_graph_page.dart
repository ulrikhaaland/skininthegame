/// Timeseries chart with example of updating external state based on selection.
///
/// A SelectionModelConfig can be provided for each of the different
/// [SelectionModel] (currently info and action).
///
/// [SelectionModelType.info] is the default selection chart exploration type
/// initiated by some tap event. This is a different model from
/// [SelectionModelType.action] which is typically used to select some value as
/// an input to some other UI component. This allows dual state of exploring
/// and selecting data via different touch events.
///
/// See [SelectNearest] behavior on setting the different ways of triggering
/// [SelectionModel] updates from hover & click events.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/resultgame.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/pages/profile/profile_page_results.dart';

class SelectionCallbackExample extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final User user;
  final bool isTournament;

  SelectionCallbackExample(this.seriesList,
      {this.animate, this.user, this.isTournament});

  /// Creates a [charts.TimeSeriesChart] with sample data and no transition.
  factory SelectionCallbackExample.withSampleData(
      charts.Series<ResultGame, DateTime> tournament,
      User user,
      bool isTournament) {
    return new SelectionCallbackExample(
      _createSampleData(tournament),
      // Disable animations for image tests.
      animate: true,
      user: user,
      isTournament: isTournament,
    );
  }

  // We need a Stateful widget to build the selection details with the current
  // selection as the state.
  @override
  State<StatefulWidget> createState() => new _SelectionCallbackState();

  /// Create one series with sample hard coded data.
  static List<charts.Series<ResultGame, DateTime>> _createSampleData(
      charts.Series<ResultGame, DateTime> tournament) {
    // final tournament = [
    //   tournament1.data[0].date,
    //   tournament1.data[0],
    // ];

    // final cashgame = [
    //   new TimeSeriesSales(new DateTime(2017, 9, 19), 15),
    //   new TimeSeriesSales(new DateTime(2017, 9, 26), 33),
    //   new TimeSeriesSales(new DateTime(2017, 10, 3), 68),
    //   new TimeSeriesSales(new DateTime(2017, 10, 10), 48),
    // ];

    return [
      tournament
      // new charts.Series<ResultGame, DateTime>(
      //   id: 'US Sales',
      //   domainFn: (ResultGame game, _) => game.date,
      //   measureFn: (ResultGame game, _) => int.tryParse(game.profit),
      //   data: tournament,
      // ),
      // new charts.Series<ResultGame, DateTime>(
      //   id: ' Sales',
      //   domainFn: (ResultGame game, _) => game.date,
      //   measureFn: (ResultGame game, _) => int.tryParse(game.profit),
      //   data: cashgame,
      // ),
    ];
  }
}

class _SelectionCallbackState extends State<SelectionCallbackExample> {
  DateTime _time;
  Map<int, ResultGame> _measures;
  var color = charts.MaterialPalette.white;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.user.nightMode != true) {
      color = charts.MaterialPalette.black;
    }
  }

  // Mapens to the underlying selection changes, and updates the information
  // relevant to building the primitive legend like information under the
  // chart.
  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    DateTime time;
    final Map<int, ResultGame> measures = new Map();

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    //
    // Walk the selection updating the measures map, storing off the sales and
    // series name for each selection point.
    if (selectedDatum.isNotEmpty) {
      time = selectedDatum.first.datum.date;
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.index] = datumPair.datum;
      });
    }

    // Request a build.
    setState(() {
      _time = time;
      _measures = measures;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    final children = <Widget>[
      new SizedBox(
          height: deviceSize.height / 2,
          child: new Padding(
              padding: EdgeInsets.all(3),
              child: new charts.TimeSeriesChart(
                widget.seriesList,
                animate: widget.animate,
                primaryMeasureAxis: charts.NumericAxisSpec(
                    renderSpec: charts.GridlineRendererSpec(
                        labelStyle:
                            charts.TextStyleSpec(fontSize: 12, color: color),
                        lineStyle: charts.LineStyleSpec(
                            thickness: 1,
                            color: charts.MaterialPalette.gray.shadeDefault))),
                domainAxis: new charts.DateTimeAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                      axisLineStyle: charts.LineStyleSpec(
                        color: color,
                      ),
                      labelStyle: new charts.TextStyleSpec(
                        fontSize: 12,
                        color: color,
                      ),
                      lineStyle:
                          charts.LineStyleSpec(thickness: 1, color: color)),
                ),
                selectionModels: [
                  new charts.SelectionModelConfig(
                    type: charts.SelectionModelType.info,
                    changedListener: _onSelectionChanged,
                  )
                ],
              ))),
    ];

    _measures?.forEach((int, ResultGame game) {
      children.add(tournamentList(game));
    });

    return new Column(children: children);
  }

  Widget tournamentList(ResultGame game) {
    Color color;
    String name = game.groupName;
    String currency = game.currency;
    String profit = game.profit;
    String tournamentOrCash = "Placing: ${game.placing}/${game.playerAmount}";
    String title = "Tournament";
    IconData tournamentOrCashIcon = Icons.whatshot;
    if (widget.isTournament != true) {
      tournamentOrCash = "Blinds: ${game.sBlind}/${game.bBlind}";
      tournamentOrCashIcon = Icons.attach_money;
      title = "Cash Game";
    }
    if (int.tryParse(game.profit).isNegative) {
      color = Colors.red;
    } else {
      color = Colors.green;
    }
    if (name.length > 13) {
      name = name.substring(0, 10);
      name = name + "...";
    }
    if (currency.length >= 6) {
      currency = currency.substring(0, 3);
      currency = currency + "...";
    }
    if (profit.length >= 11) {
      profit = profit.substring(0, 9);
      profit = profit + "...";
    }
    return ListTile(
      contentPadding: EdgeInsets.all(3.0),
      leading: new Icon(
        tournamentOrCashIcon,
        color: color,
        size: 40.0,
      ),
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(
            name,
            textAlign: TextAlign.start,
            style: new TextStyle(color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
          ),
          new Text(
            "${game.date.day}/${game.date.month}/${game.date.year} ${game.time}",
            style: new TextStyle(color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
      subtitle: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(
            tournamentOrCash,
            textAlign: TextAlign.start,
            style: new TextStyle(color: UIData.blackOrWhite),
          ),
          new Text(
            "Profit: $profit$currency",
            style: new TextStyle(color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePageResults(
                    user: widget.user,
                    result: game,
                    title: title,
                  ))),
    );
  }
}
