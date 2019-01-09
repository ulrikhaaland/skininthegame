import 'package:flutter/material.dart';
import 'package:yadda/objects/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:yadda/objects/resultgame.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:yadda/pages/results/results_graph_page.dart';
import 'results.dart';
import 'package:yadda/utils/uidata.dart';

class Blabla extends StatefulWidget {
  final User user;
  Blabla({this.user});
  @override
  _BlablaState createState() => _BlablaState();
}

class _BlablaState extends State<Blabla> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tournament = new List();
    _tabController = new TabController(vsync: this, length: 2);

    getData();
  }

  charts.Series<ResultGame, DateTime> data;
  List<ResultGame> tournament;

  void getData() async {
    QuerySnapshot qSnap = await Firestore.instance
        .collection("users/${widget.user.id}/tournamentresults")
        .getDocuments();
    qSnap.documents.forEach((DocumentSnapshot doc) {
      ResultGame resultGame = ResultGame.fromMap(doc.data);
      tournament.add(resultGame);
    });
    tournament.sort((a, b) => a.date.compareTo(b.date));
    data = charts.Series<ResultGame, DateTime>(
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      id: 'US Sales',
      domainFn: (ResultGame game, _) => game.date,
      measureFn: (ResultGame game, _) => int.tryParse(game.profit),
      data: tournament,

      // fillColorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
    );

    for (int i = 0; i < tournament.length; i++) {
      List<ResultGame> tournament1 = new List();
      tournament1.addAll(tournament);
      tournament1.removeAt(i);
      String date1 = tournament[i].date.year.toString() +
          tournament[i].date.month.toString() +
          tournament[i].date.day.toString();
      for (int e = 0; e < tournament1.length; e++) {
        String date2 = tournament1[e].date.year.toString() +
            tournament1[e].date.month.toString() +
            tournament1[e].date.day.toString();
        if (date1 == date2) {
          print("true");
        }
      }
    }
    // QuerySnapshot qSnap2 = await Firestore.instance
    //     .collection("users/${widget.user.id}/cashgameresults")
    //     .getDocuments();
    // qSnap2.documents.forEach((DocumentSnapshot doc) {
    //   ResultGame resultGame = ResultGame.fromMap(doc.data);
    //   cashgame.add(resultGame);
    // });
    // chart = new charts.Series<TimeSeriesSales, DateTime>(
    //   id: 'UK Sales',
    //   domainFn: (TimeSeriesSales sales, _) => data[0].time,
    //   measureFn: (TimeSeriesSales sales, _) => 40,
    //   data: data,
    // );
    setState(() {
      ready = true;
    });
  }

  bool ready = false;
  var chart;
  @override
  Widget build(BuildContext context) {
    if (ready)
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
                  "Cash Games",
                  style: new TextStyle(color: UIData.blackOrWhite),
                ),
              ),
              Tab(
                child: Text(
                  "Tournaments",
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
                    SelectionCallbackExample.withSampleData(data, widget.user)
                  ],
                ),
              )
            ],
          ),
        ]),
        backgroundColor: UIData.dark,
      );
    else
      return Scaffold(backgroundColor: UIData.dark, body: new Container());
  }
}
