import 'package:flutter/material.dart';
import 'package:yadda/objects/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:yadda/objects/resultgame.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:yadda/pages/results/results_graph_page.dart';
import 'results.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/utils/essentials.dart';

class Blabla extends StatefulWidget {
  final User user;
  bool isLoading;
  Blabla({this.user, this.isLoading});
  @override
  _BlablaState createState() => _BlablaState();
}

class _BlablaState extends State<Blabla> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tournamentResults = new List();
    cashgameResults = new List();

    _tabController = new TabController(vsync: this, length: 3);

    getData();
  }

  charts.Series<ResultGame, DateTime> tournamentData;
  List<ResultGame> tournamentResults;
  charts.Series<ResultGame, DateTime> cashgameData;
  List<ResultGame> cashgameResults;
  ResultGameTotal cashResultGameTotal;
  ResultGameTotal tournamentResultGameTotal;

  void getData() async {
    QuerySnapshot cSnap = await Firestore.instance
        .collection("users/${widget.user.id}/cashgameresults")
        .getDocuments();
    cSnap.documents.forEach((DocumentSnapshot doc) {
      ResultGame resultGame = ResultGame.fromMap(doc.data);
      cashgameResults.add(resultGame);
    });
    cashResultGameTotal = new ResultGameTotal(0, 0, 0, 0, 0, 0, 0);
    for (int i = 0; i < cashgameResults.length; i++) {
      if (!int.tryParse(cashgameResults[i].profit).isNegative) {
        cashResultGameTotal.winningSessions += 1;
      }

      cashResultGameTotal.averageBuyin += cashgameResults[i].buyin.toDouble();

      cashResultGameTotal.totalProfit +=
          int.tryParse(cashgameResults[i].profit);
      if (i == cashgameResults.length - 1) {
        cashResultGameTotal.averageProfit =
            cashResultGameTotal.totalProfit / cashgameResults.length;
        cashResultGameTotal.winningSessionsPercentage =
            cashResultGameTotal.winningSessions / cashgameResults.length;
        cashResultGameTotal.averageBuyin =
            cashResultGameTotal.averageBuyin / cashgameResults.length;
      }
    }
    cashResultGameTotal.gameCount = cashgameResults.length + 1;

    cashgameResults.sort((a, b) => a.date.compareTo(b.date));
    cashgameData = charts.Series<ResultGame, DateTime>(
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      id: 'Cashgame',
      domainFn: (ResultGame game, _) => game.date,
      measureFn: (ResultGame game, _) => int.tryParse(game.profit),
      data: cashgameResults,
    );
    QuerySnapshot qSnap = await Firestore.instance
        .collection("users/${widget.user.id}/tournamentresults")
        .getDocuments();
    qSnap.documents.forEach((DocumentSnapshot doc) {
      ResultGame resultGame = ResultGame.fromMap(doc.data);
      tournamentResults.add(resultGame);
    });
    tournamentResultGameTotal = new ResultGameTotal(0, 0, 0, 0, 0, 0, 0);
    for (int i = 0; i < tournamentResults.length; i++) {
      if (int.tryParse(tournamentResults[i].payout) > 0) {
        tournamentResultGameTotal.itm += 1;
      }
      if (!int.tryParse(tournamentResults[i].profit).isNegative) {
        tournamentResultGameTotal.winningSessions += 1;
      }

      tournamentResultGameTotal.averageBuyin +=
          tournamentResults[i].buyin.toDouble();

      tournamentResultGameTotal.totalProfit +=
          int.tryParse(tournamentResults[i].profit);
      if (i == tournamentResults.length - 1) {
        tournamentResultGameTotal.averageProfit =
            tournamentResultGameTotal.totalProfit / tournamentResults.length;
        tournamentResultGameTotal.winningSessionsPercentage =
            tournamentResultGameTotal.winningSessions /
                tournamentResults.length;
        tournamentResultGameTotal.itm =
            tournamentResultGameTotal.itm / tournamentResults.length;
        tournamentResultGameTotal.averageBuyin =
            tournamentResultGameTotal.averageBuyin / tournamentResults.length;
      }
    }
    tournamentResultGameTotal.gameCount = cashgameResults.length + 1;

    tournamentResults.sort((a, b) => a.date.compareTo(b.date));
    tournamentData = charts.Series<ResultGame, DateTime>(
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      id: 'Tournament',
      domainFn: (ResultGame game, _) => game.date,
      measureFn: (ResultGame game, _) => int.tryParse(game.profit),
      data: tournamentResults,
    );

    setState(() {
      widget.isLoading = false;
    });
  }

  bool ready = false;
  var chart;
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading)
      return Scaffold(
        appBar: AppBar(
          title: new Text(
            "Results",
            style: new TextStyle(
                color: UIData.blackOrWhite, fontSize: UIData.fontSize24),
          ),
          backgroundColor: UIData.appBarColor,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(
                  "Tournaments",
                  style: new TextStyle(color: UIData.blackOrWhite),
                ),
              ),
              Tab(
                child: Text(
                  "Cash Games",
                  style: new TextStyle(color: UIData.blackOrWhite),
                ),
              ),
              Tab(
                child: Text(
                  "Statistics",
                  style: new TextStyle(color: UIData.blackOrWhite),
                ),
              ),
            ],
          ),
        ),
        body: new Stack(children: <Widget>[
          new TabBarView(
            physics: ScrollPhysics(),
            controller: _tabController,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                    ),
                    SelectionCallbackExample.withSampleData(
                        tournamentData, widget.user, true)
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                    ),
                    SelectionCallbackExample.withSampleData(
                        cashgameData, widget.user, false)
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: new Column(
                    children: data(),
                  ),
                ),
              ),
            ],
          ),
        ]),
        backgroundColor: UIData.dark,
      );
    else
      return Essentials();
  }

  List<Widget> data() {
    List<Widget> list = new List<Widget>();

    if (tournamentResults != null) {
      list.add(new Align(
        alignment: Alignment.center,
        child: new Text(
          "Tournaments",
          style: new TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize24),
        ),
      ));
      list.add(new Container(
        height: 14,
      ));
    }
    if (tournamentResultGameTotal.gameCount != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Count: ${tournamentResultGameTotal.gameCount}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (tournamentResultGameTotal.itm != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "ITM: ${tournamentResultGameTotal.itm * 100}%",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (tournamentResultGameTotal.totalProfit != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Total profit: ${tournamentResultGameTotal.totalProfit}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (tournamentResultGameTotal.averageProfit != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Average profit: ${tournamentResultGameTotal.averageProfit}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (tournamentResultGameTotal.averageBuyin != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Average buyin: ${tournamentResultGameTotal.averageBuyin}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (tournamentResultGameTotal.winningSessions != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Winning sessions: ${tournamentResultGameTotal.winningSessions}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (tournamentResultGameTotal.winningSessions != null) {
      int loosing = tournamentResultGameTotal.winningSessions -
          tournamentResultGameTotal.gameCount;
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Loosing sessions: ${loosing}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    list.add(new Container(
      height: 44,
    ));

    if (cashgameResults != null) {
      list.add(new Align(
        alignment: Alignment.center,
        child: new Text(
          "Cash Games",
          style: new TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize24),
        ),
      ));
      list.add(new Container(
        height: 14,
      ));
    }
    if (cashResultGameTotal.gameCount != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Count: ${cashResultGameTotal.gameCount}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (cashResultGameTotal.winningSessionsPercentage != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Win%: ${cashResultGameTotal.winningSessionsPercentage * 100}%",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (cashResultGameTotal.totalProfit != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Total profit: ${cashResultGameTotal.totalProfit}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (cashResultGameTotal.averageProfit != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Average profit: ${cashResultGameTotal.averageProfit}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (cashResultGameTotal.averageBuyin != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Average buyin: ${cashResultGameTotal.averageBuyin}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (cashResultGameTotal.winningSessions != null) {
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Winning sessions: ${cashResultGameTotal.winningSessions}",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    if (cashResultGameTotal.winningSessions != null) {
      int loosing =
          cashResultGameTotal.gameCount - cashResultGameTotal.winningSessions;
      list.add(
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
              "Loosing sessions: $loosing",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
              ),
            )),
      );
    }

    return list;
  }
}
