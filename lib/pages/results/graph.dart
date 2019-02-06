import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:yadda/objects/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/resultgame.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:yadda/pages/results/results_graph_page.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/utils/essentials.dart';
import 'results_settings.dart';
import 'package:yadda/objects/currency.dart';

class ResultPage extends StatefulWidget {
  final User user;
  final User currentUser;
  bool isLoading;
  ResultPage({this.user, this.isLoading, this.currentUser});
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with TickerProviderStateMixin {
  TabController _tabController;
  Currency currency = new Currency();
  charts.Series<ResultGame, DateTime> tournamentData;
  List<ResultGame> tournamentResults;
  charts.Series<ResultGame, DateTime> cashgameData;
  List<ResultGame> cashgameResults;
  ResultGameTotal cashResultGameTotal;
  ResultGameTotal tournamentResultGameTotal;

  @override
  void initState() {
    super.initState();
    tournamentResults = new List();
    cashgameResults = new List();

    _tabController = new TabController(vsync: this, length: 3);

    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading)
      return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(
              defaultTargetPlatform == TargetPlatform.android
                  ? Icons.arrow_back
                  : Icons.arrow_back_ios,
              color: UIData.blackOrWhite,
            ),
            onPressed: () =>
                Navigator.canPop(context) ? Navigator.pop(context) : null,
          ),
          actions: <Widget>[
            new Padding(
              padding: EdgeInsets.only(right: 10),
              child: Theme(
                data:
                    Theme.of(context).copyWith(canvasColor: UIData.appBarColor),
                child: new Container(
                    color: UIData.appBarColor,
                    child: new DropdownButton<String>(
                      style: TextStyle(color: UIData.blackOrWhite),
                      hint: new Text(
                        widget.currentUser.currency,
                        style: new TextStyle(
                            color: UIData.blackOrWhite,
                            fontWeight: FontWeight.bold),
                      ),
                      items: <String>['USD', 'EURO', 'NOK', 'GBP']
                          .map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(
                            value,
                            style: new TextStyle(color: UIData.blackOrWhite),
                          ),
                        );
                      }).toList(),
                      onChanged: (_) {
                        widget.isLoading = true;
                        if (widget.currentUser.currency != _) {
                          setState(() {
                            widget.isLoading = true;
                            getData();
                            widget.currentUser.currency = _;
                          });
                        }
                      },
                    )),
              ),
            ),
          ],
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
                    hasTournaments(),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    hasCashGames(),
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

  ResultGame exchange(ResultGame resultGame) {
    double rate = 0;
    switch (widget.currentUser.currency) {
      case ("NOK"):
        {
          switch (resultGame.currency) {
            case ("USD"):
              rate = currency.usd.nok;
              break;
            case ("EURO"):
              rate = currency.euro.nok;
              break;
            case ("GBP"):
              rate = currency.gbp.nok;
              break;
          }
        }
        break;
      case ("USD"):
        {
          switch (resultGame.currency) {
            case ("NOK"):
              rate = currency.nok.usd;
              break;
            case ("EURO"):
              rate = currency.euro.usd;
              break;
            case ("GBP"):
              rate = currency.gbp.usd;
              break;
          }
        }
        break;
      case ("EURO"):
        {
          switch (resultGame.currency) {
            case ("USD"):
              rate = currency.usd.euro;
              break;
            case ("NOK"):
              rate = currency.nok.euro;
              break;
            case ("GBP"):
              rate = currency.gbp.euro;
              break;
          }
        }
        break;
      case ("GBP"):
        {
          switch (resultGame.currency) {
            case ("USD"):
              rate = currency.usd.gbp;
              break;
            case ("EURO"):
              rate = currency.euro.gbp;
              break;
            case ("NOK"):
              rate = currency.nok.gbp;
              break;
          }
        }
        break;
    }
    print(rate);
    double buyin = resultGame.buyin * rate;
    double payout = resultGame.payout * rate;
    double profit = resultGame.profit * rate;
    double bBlind;
    double sBlind;
    if (resultGame.type == 0) {
      bBlind = resultGame.bBlind * rate;
      sBlind = resultGame.sBlind * rate;
    }

    if (resultGame.type == 0) {
      resultGame = new ResultGame(
          null,
          buyin.round(),
          widget.currentUser.currency,
          resultGame.gameName,
          resultGame.gameType,
          resultGame.groupName,
          resultGame.orderByTime,
          payout.round(),
          null,
          resultGame.playerAmount,
          null,
          profit.round(),
          null,
          resultGame.time,
          bBlind.round(),
          sBlind.round(),
          resultGame.date,
          resultGame.share,
          resultGame.type);
    } else {
      resultGame = new ResultGame(
          resultGame.addon,
          buyin.round(),
          widget.currentUser.currency,
          resultGame.gameName,
          resultGame.gameType,
          resultGame.groupName,
          resultGame.orderByTime,
          payout.round(),
          resultGame.placing,
          resultGame.playerAmount,
          resultGame.prizePool,
          profit.round(),
          resultGame.rebuy,
          resultGame.time,
          null,
          null,
          resultGame.date,
          resultGame.share,
          resultGame.type);
    }

    return resultGame;
  }

  bool globalCurrency = false;
  void getData() async {
    cashgameResults.removeRange(0, cashgameResults.length);
    tournamentResults.removeRange(0, tournamentResults.length);
    currency.classes();
    QuerySnapshot cSnap = await Firestore.instance
        .collection("users/${widget.user.id}/cashgameresults")
        .getDocuments();
    cSnap.documents.forEach((DocumentSnapshot doc) {
      ResultGame resultGame = ResultGame.fromMap(doc.data);
      cashgameResults.add(resultGame);
    });
    cashResultGameTotal = new ResultGameTotal(0, 0, 0, 0, 0, 0, 0);
    for (int i = 0; i < cashgameResults.length; i++) {
      if (cashgameResults[i].currency != widget.currentUser.currency) {
        if (cashgameResults[i].currency == "NOK" ||
            cashgameResults[i].currency == "USD" ||
            cashgameResults[i].currency == "EURO" ||
            cashgameResults[i].currency == "GBP") {
          globalCurrency = true;
          cashgameResults[i] = exchange(cashgameResults[i]);
        }
      }
      if (!cashgameResults[i].share &&
          widget.user.id != widget.currentUser.id) {
        cashgameResults.removeAt(i);
      }
      if (!cashgameResults[i].profit.isNegative) {
        cashResultGameTotal.winningSessions += 1;
      }

      cashResultGameTotal.averageBuyin += cashgameResults[i].buyin.toDouble();

      cashResultGameTotal.totalProfit += cashgameResults[i].profit;
      if (i == cashgameResults.length - 1) {
        cashResultGameTotal.averageProfit =
            cashResultGameTotal.totalProfit / cashgameResults.length;
        cashResultGameTotal.winningSessionsPercentage =
            cashResultGameTotal.winningSessions / cashgameResults.length;
        cashResultGameTotal.averageBuyin =
            cashResultGameTotal.averageBuyin / cashgameResults.length;
      }
    }
    cashResultGameTotal.gameCount = cashgameResults.length;

    cashgameResults.sort((a, b) => a.date.compareTo(b.date));
    cashgameData = charts.Series<ResultGame, DateTime>(
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      id: 'Cashgame',
      domainFn: (ResultGame game, _) => game.date,
      measureFn: (ResultGame game, _) => game.profit,
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
      if (tournamentResults[i].currency != widget.currentUser.currency) {
        if (tournamentResults[i].currency == "NOK" ||
            tournamentResults[i].currency == "USD" ||
            tournamentResults[i].currency == "EURO" ||
            tournamentResults[i].currency == "GBP") {
          tournamentResults[i] = exchange(tournamentResults[i]);
        }
      }
      if (!tournamentResults[i].share &&
          widget.user.id != widget.currentUser.id) {
        tournamentResults.removeAt(i);
      }
      if (tournamentResults[i].payout > 0) {
        tournamentResultGameTotal.itm += 1;
      }
      if (!tournamentResults[i].profit.isNegative) {
        tournamentResultGameTotal.winningSessions += 1;
      }

      tournamentResultGameTotal.averageBuyin +=
          tournamentResults[i].buyin.toDouble();

      tournamentResultGameTotal.totalProfit += tournamentResults[i].profit;
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
    tournamentResultGameTotal.gameCount = tournamentResults.length;

    tournamentResults.sort((a, b) => a.date.compareTo(b.date));
    tournamentData = charts.Series<ResultGame, DateTime>(
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      id: 'Tournament',
      domainFn: (ResultGame game, _) => game.date,
      measureFn: (ResultGame game, _) => game.profit,
      data: tournamentResults,
    );

    setState(() {
      widget.isLoading = false;
    });
  }

  Widget hasTournaments() {
    if (tournamentResults.isNotEmpty) {
      return SelectionCallbackExample.withSampleData(
          tournamentData, widget.currentUser, true);
    } else {
      return notSharing("tournament");
    }
  }

  Widget hasCashGames() {
    if (cashgameResults.isNotEmpty) {
      return SelectionCallbackExample.withSampleData(
          cashgameData, widget.currentUser, false);
    } else {
      return notSharing("cash game");
    }
  }

  Widget notSharing(String type) {
    return new Padding(
        padding: EdgeInsets.all(12.0),
        child: new Align(
          alignment: Alignment.topCenter,
          child: new Container(
            decoration: new BoxDecoration(
                color: UIData.listColor,
                border: Border.all(color: Colors.grey[600]),
                borderRadius: new BorderRadius.all(const Radius.circular(8.0))),
            child: new Padding(
                padding: EdgeInsets.all(12.0),
                child: new Text(
                  "${widget.user.userName} has no $type results to share",
                  style:
                      new TextStyle(fontSize: 25.0, color: UIData.blackOrWhite),
                )),
          ),
        ));
  }

  List<Widget> data() {
    List<Widget> list = new List<Widget>();
    if (tournamentResults.isNotEmpty) {
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
                "Total profit: ${tournamentResultGameTotal.totalProfit.round()}",
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
                "Average profit: ${tournamentResultGameTotal.averageProfit.round()}",
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
                "Average buyin: ${tournamentResultGameTotal.averageBuyin.round()}",
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
        int loosing = tournamentResultGameTotal.gameCount -
            tournamentResultGameTotal.winningSessions;
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
    }

    if (tournamentResults.isNotEmpty) {
      list.add(new Container(
        height: 44,
      ));
    }

    if (cashgameResults.isNotEmpty) {
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
                "Total profit: ${cashResultGameTotal.totalProfit.round()}",
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
                "Average profit: ${cashResultGameTotal.averageProfit.round()}",
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
                "Average buyin: ${cashResultGameTotal.averageBuyin.round()}",
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
    }
    return list;
  }
}
