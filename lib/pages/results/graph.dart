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

    _tabController = new TabController(vsync: this, length: 2);

    getData();
  }

  charts.Series<ResultGame, DateTime> tournamentData;
  List<ResultGame> tournamentResults;
  charts.Series<ResultGame, DateTime> cashgameData;
  List<ResultGame> cashgameResults;

  void getData() async {
    QuerySnapshot cSnap = await Firestore.instance
        .collection("users/${widget.user.id}/cashgameresults")
        .getDocuments();
    cSnap.documents.forEach((DocumentSnapshot doc) {
      ResultGame resultGame = ResultGame.fromMap(doc.data);
      cashgameResults.add(resultGame);
    });
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
            ],
          ),
        ]),
        backgroundColor: UIData.dark,
      );
    else
      return Essentials();
  }
}
