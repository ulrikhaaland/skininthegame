import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/user.dart';
import 'tournament_createPlayer_page.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/objects/game.dart';
import 'package:yadda/utils/delete.dart';
import 'package:yadda/pages/inAppPurchase/subscription.dart';

class TournamentSettingsPage extends StatefulWidget {
  TournamentSettingsPage({
    Key key,
    this.group,
    this.user,
    this.initState,
    this.history,
    this.callBack,
    this.game,
  }) : super(key: key);
  final Group group;
  final User user;
  final Game game;
  final VoidCallback initState;
  final bool history;
  final VoidCallback callBack;
  @override
  TournamentSettingsPageState createState() => TournamentSettingsPageState();
}

enum FormType { public, private }

class TournamentSettingsPageState extends State<TournamentSettingsPage>
    with TickerProviderStateMixin {
  static final formKey = new GlobalKey<FormState>();

  TabController _tabController;

  final Firestore firestoreInstance = Firestore.instance;

  String currentUserId;
  String currentUserName;

  String groupId;

  String date;
  String time;

  // New game

  bool isLoading = false;

  CollectionReference fromCollectionPlayers;
  CollectionReference fromCollectionPosts;
  CollectionReference fromCollectionLog;
  String pathToTournament;
  String tournamentActiveOrHistory = "tournamentactive";

  DateTime _date;
  TimeOfDay _time;

  @override
  initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);

    currentUserId = widget.user.id;
    currentUserName = widget.user.userName;
    groupId = widget.group.id;
    if (widget.history == true) {
      tournamentActiveOrHistory = "tournamenthistory";
    }

    _date = new DateTime(
        int.tryParse(widget.game.orderByTime.toString().substring(0, 4)),
        int.tryParse(widget.game.orderByTime.toString().substring(4, 6)),
        int.tryParse(widget.game.orderByTime.toString().substring(6, 8)));
    _time = new TimeOfDay(
        hour: int.tryParse(widget.game.orderByTime.toString().substring(8, 10)),
        minute:
            int.tryParse(widget.game.orderByTime.toString().substring(10, 12)));
    pathToTournament =
        "groups/$groupId/games/type/$tournamentActiveOrHistory/${widget.game.id}";

    fromCollectionPlayers =
        firestoreInstance.collection("$pathToTournament/players");
    fromCollectionPosts =
        firestoreInstance.collection("$pathToTournament/posts");
    fromCollectionLog = firestoreInstance.collection("$pathToTournament/log");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return page();
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  Widget loadingTwo() {
    if (isLoading == true) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new Container();
    }
  }

  void _saveGame() {
    if (validateAndSave()) {
      String month = _date.month.toString();
      String day = _date.day.toString();
      String hour = _time.hour.toString();
      String minute = _time.minute.toString();

      if (month.length == 1) month = "0" + month;
      if (day.length == 1) day = "0" + day;
      if (hour.length == 1) hour = "0" + hour;
      if (minute.length == 1) minute = "0" + minute;

      String orderByTime = "${_date.year}$month$day$hour$minute";
      widget.game.setOrderByTime(int.tryParse(orderByTime));
      widget.game.pushGameToFirestore(pathToTournament, true);
      Log().postLogToCollection(
          "$currentUserName updated game. Name: ${widget.game.name}, Adress: ${widget.game.adress}, Date: ${widget.game.date}, Time: ${widget.game.time}, Maxplayers: ${widget.game.maxPlayers}, Buyin: ${widget.game.buyin} Rebuys: ${widget.game.rebuy}, Addon: ${widget.game.addon}, Starting chips: ${widget.game.startingChips}, Prize pool: ${widget.game.totalPrizePool} Gametype: ${widget.game.gameType}, Gameinfo: ${widget.game.info}",
          "$pathToTournament/log",
          "Update");
      showSnackBar("Game has been updated");
    }
  }

  void showSnackBar(String message) {
    Scaffold.of(formKey.currentState.context).showSnackBar(new SnackBar(
      backgroundColor: UIData.yellow,
      content: new Text(
        message,
        textAlign: TextAlign.center,
        style: new TextStyle(color: Colors.black),
      ),
    ));
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 18.0),
      child: child,
    );
  }

  Widget paddedTwo({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: child,
    );
  }

  Scaffold page() {
    return Scaffold(
        backgroundColor: UIData.dark,
        appBar: AppBar(
          iconTheme: IconThemeData(color: UIData.blackOrWhite),
          title: new Align(
              child: new Text(
            "Game Settings",
            style: new TextStyle(
                fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
          )),
          actions: <Widget>[
            new FlatButton(
                child: new Text(
                  "Update",
                  style: new TextStyle(
                      fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
                  textAlign: TextAlign.center,
                ),
                onPressed: () => _saveGame()),
          ],
          backgroundColor: UIData.appBarColor,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.edit,
                  color: UIData.blackOrWhite,
                  size: 30.0,
                ),
                text: "Edit",
              ),
              Tab(
                icon: Icon(
                  Icons.list,
                  color: Colors.grey[600],
                  size: 30.0,
                ),
                text: "Game log",
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            new Form(
              key: formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        new ListTile(
                          leading: new Icon(
                            Icons.person,
                            size: 40.0,
                            color: UIData.blue,
                          ),
                          title: new Text(
                            "Create player",
                            style: new TextStyle(
                                color: UIData.blackOrWhite,
                                fontSize: UIData.fontSize20),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TournamentCreatePlayerPage(
                                          user: widget.user,
                                          history: widget.history,
                                          group: widget.group,
                                          game: widget.game,
                                          callBack: () => widget.callBack(),
                                        )));
                          },
                        ),
                        new Divider(
                          height: .0,
                          color: Colors.black,
                        ),
                        markAsFinishedList(),
                        divider(),
                        new ListTile(
                          leading: new Icon(
                            Icons.delete,
                            size: 40.0,
                            color: UIData.red,
                          ),
                          title: new Text(
                            "Delete game",
                            style: new TextStyle(
                                color: UIData.blackOrWhite,
                                fontSize: UIData.fontSize20),
                          ),
                          onTap: () => _deleteAlert(),
                        ),
                        new Divider(
                          height: .0,
                          color: Colors.black,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                        ),
                        new TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: widget.game.name,
                          style: new TextStyle(color: UIData.blackOrWhite),
                          key: new Key('name'),
                          decoration: new InputDecoration(
                              labelText: 'Name',
                              labelStyle:
                                  new TextStyle(color: Colors.grey[600])),
                          autocorrect: false,
                          onSaved: (val) {
                            if (val.isEmpty) {
                              val = "Not Set";
                            }
                            if (val.length > 18) {
                              setState(() {
                                String fittedString = val.substring(0, 16);
                                widget.game.setName(val);
                                widget.game.setFittedName("$fittedString...");
                              });
                            } else {
                              setState(() {
                                widget.game.setName(val);
                                widget.game.setFittedName(val);
                              });
                            }
                          },
                        ),
                        new TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: widget.game.adress,
                          style: new TextStyle(color: UIData.blackOrWhite),
                          key: new Key('adress'),
                          decoration: new InputDecoration(
                              labelText: 'Adress',
                              labelStyle:
                                  new TextStyle(color: Colors.grey[600])),
                          autocorrect: false,
                          onSaved: (val) => widget.game.setAdress(val),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            paddedTwo(
                              child: new ConstrainedBox(
                                constraints: BoxConstraints.expand(
                                    height: 40.0, width: 120),
                                child: new RaisedButton(
                                    child: new Text("Date",
                                        style: new TextStyle(
                                          color: Colors.black,
                                          fontSize: UIData.fontSize16,
                                        )),
                                    shape: new RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0))),
                                    color: Colors.yellow[700],
                                    textColor: Colors.white,
                                    onPressed: () {
                                      _selectDate(context);
                                    }),
                              ),
                            ),
                            paddedTwo(
                              child: new ConstrainedBox(
                                constraints: BoxConstraints.expand(
                                    height: 40.0, width: 120),
                                child: new RaisedButton(
                                    child: new Text("Time",
                                        style: new TextStyle(
                                          color: Colors.black,
                                          fontSize: UIData.fontSize16,
                                        )),
                                    shape: new RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0))),
                                    color: Colors.yellow[700],
                                    textColor: Colors.white,
                                    onPressed: () {
                                      _selectTime(context);
                                    }),
                              ),
                            ),
                          ],
                        ),
                        new TextFormField(
                            keyboardType: TextInputType.numberWithOptions(),
                            initialValue: widget.game.maxPlayers.toString(),
                            maxLength: 6,
                            style: new TextStyle(color: UIData.blackOrWhite),
                            key: new Key('maximumplayers'),
                            decoration: new InputDecoration(
                                labelText: 'Maximum players',
                                labelStyle:
                                    new TextStyle(color: Colors.grey[600])),
                            autocorrect: false,
                            validator: (val) {
                              val.isEmpty
                                  ? val = widget.game.maxPlayers.toString()
                                  : null;

                              if (widget.user.subLevel < 2) {
                                String sub;
                                if (widget.user.subLevel == 1 &&
                                    int.tryParse(val) > 27) {
                                  sub =
                                      "Your current subscription only allows \n27 players per tournament";
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Subscription(
                                                user: widget.user,
                                                info: true,
                                                title: sub,
                                              )));
                                  return sub;
                                } else if (widget.user.subLevel == 0 &&
                                    int.tryParse(val) > 9) {
                                  sub =
                                      "Your current subscription only allows \n9 players per tournament";
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Subscription(
                                                user: widget.user,
                                                info: true,
                                                title: sub,
                                              )));
                                  return sub;
                                }
                              }
                            },
                            onSaved: (val) {
                              if (val.isEmpty) {
                                switch (widget.user.subLevel) {
                                  case (0):
                                    widget.game.setMaxPlayers(9);
                                    break;
                                  case (1):
                                    widget.game.setMaxPlayers(18);
                                    break;
                                  case (2):
                                    widget.game.setMaxPlayers(27);
                                    break;
                                }
                              } else if (widget.user.subLevel == 1 &&
                                  int.tryParse(val) > 27) {
                                widget.game.setMaxPlayers(27);
                              } else if (widget.user.subLevel == 0 &&
                                  int.tryParse(val) > 9) {
                                widget.game.setMaxPlayers(9);
                              } else {
                                widget.game.setMaxPlayers(int.tryParse(val));
                              }
                            }),
                        new TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: widget.game.gameType,
                          style: new TextStyle(color: UIData.blackOrWhite),
                          key: new Key('gametype'),
                          decoration: new InputDecoration(
                              labelText: 'Gametype',
                              labelStyle:
                                  new TextStyle(color: Colors.grey[600])),
                          autocorrect: false,
                          onSaved: (val) => widget.game.setGameType(val),
                        ),
                        new TextFormField(
                          keyboardType: TextInputType.numberWithOptions(),
                          initialValue: widget.game.buyin.toString(),
                          maxLength: 10,
                          style: new TextStyle(color: UIData.blackOrWhite),
                          key: new Key('buyin'),
                          decoration: new InputDecoration(
                              labelText: 'Buyin',
                              labelStyle:
                                  new TextStyle(color: Colors.grey[600])),
                          autocorrect: false,
                          onSaved: (val) =>
                              widget.game.setBuyin(int.tryParse(val)),
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            paddedTwo(
                              child: new Container(
                                width: 120,
                                child: new TextFormField(
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  initialValue: widget.game.rebuy.toString(),
                                  keyboardAppearance: Brightness.dark,
                                  style:
                                      new TextStyle(color: UIData.blackOrWhite),
                                  key: new Key('rebuy'),
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Rebuys",
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[600])),
                                  autocorrect: false,
                                  onSaved: (val) =>
                                      widget.game.setRebuy(int.tryParse(val)),
                                ),
                              ),
                            ),
                            paddedTwo(
                              child: new Container(
                                width: 120,
                                child: new TextFormField(
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    initialValue: widget.game.addon.toString(),
                                    keyboardAppearance: Brightness.dark,
                                    style: new TextStyle(
                                        color: UIData.blackOrWhite),
                                    key: new Key('addon'),
                                    decoration: new InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Addon",
                                        labelStyle: new TextStyle(
                                            color: Colors.grey[600])),
                                    autocorrect: false,
                                    onSaved: (val) => widget.game
                                        .setAddon(int.tryParse(val))),
                              ),
                            ),
                          ],
                        ),
                        new TextFormField(
                          keyboardType: TextInputType.numberWithOptions(),
                          initialValue: widget.game.startingChips,
                          style: new TextStyle(color: UIData.blackOrWhite),
                          key: new Key('startingchips'),
                          decoration: new InputDecoration(
                              labelText: 'Starting chips',
                              labelStyle:
                                  new TextStyle(color: Colors.grey[600])),
                          autocorrect: false,
                          onSaved: (val) => widget.game.setStartingChips(val),
                        ),
                        new TextFormField(
                          initialValue: widget.game.totalPrizePool,
                          maxLines: 3,
                          style: new TextStyle(color: UIData.blackOrWhite),
                          key: new Key('totalprizepool'),
                          decoration: new InputDecoration(
                              labelText: 'Total prize pool',
                              labelStyle:
                                  new TextStyle(color: Colors.grey[600])),
                          autocorrect: false,
                          onSaved: (val) => widget.game.setTotalPrizePool(val),
                        ),
                        new TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            style: new TextStyle(color: UIData.blackOrWhite),
                            key: new Key('currency'),
                            initialValue: widget.game.currency,
                            decoration: new InputDecoration(
                                labelText: 'Currency',
                                labelStyle:
                                    new TextStyle(color: Colors.grey[600])),
                            autocorrect: false,
                            onSaved: (val) => val.isEmpty
                                ? widget.game.setCurrency(widget.user.currency)
                                : widget.game.setCurrency(val)),
                        new TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: widget.game.info,
                          maxLines: 3,
                          style: new TextStyle(color: UIData.blackOrWhite),
                          key: new Key('info'),
                          decoration: new InputDecoration(
                              labelText: 'Additional information',
                              labelStyle:
                                  new TextStyle(color: Colors.grey[600])),
                          autocorrect: false,
                          onSaved: (val) => widget.game.setInfo(val),
                        ),
                      ],
                    ),
                  ),
                  streamOfLog(),
                ],
              ),
            ),
            loadingTwo(),
          ],
        ));
  }

  Widget markAsFinishedList() {
    if (widget.history != true && widget.game.isRunning == false) {
      return new ListTile(
        leading: new Icon(
          Icons.play_circle_outline,
          size: 40.0,
          color: UIData.green,
        ),
        title: new Text(
          "Start game",
          style: new TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
        ),
        onTap: () {
          firestoreInstance.document(pathToTournament).updateData({
            "isrunning": true,
          });

          setState(() {
            widget.game.isRunning = true;
          });
          showSnackBar("Game has started!");
        },
      );
    } else if (widget.history != true && widget.game.isRunning == true) {
      return new ListTile(
        leading: new Icon(
          Icons.cancel,
          size: 40.0,
          color: UIData.green,
        ),
        title: new Text(
          "End game",
          style: new TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
        ),
        onTap: () => _finishedAlert(),
      );
    } else {
      return new Container();
    }
  }

  divider() {
    if (widget.history != true) {
      return new Divider(
        height: .0,
        color: Colors.black,
      );
    } else {
      return new Container();
    }
  }

  int calculateProfits(int payout, int rebuy, int addon) {
    int profit = -widget.game.buyin;
    for (int i = 0; i < rebuy; i++) {
      profit -= widget.game.buyin;
    }
    for (int i = 0; i < addon; i++) {
      profit -= widget.game.buyin;
    }
    int finalProfit;
    if (payout != null) {
      profit += payout;
      finalProfit = profit;
    } else {
      finalProfit = payout;
    }
    return finalProfit;
  }

  Future<Null> saveResults() async {
    String string = widget.game.orderByTime.toString();
    if (string != "0") {
      string = string.substring(0, 4);
    }
    await firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot qSnap = await firestoreInstance
          .collection("$pathToTournament/activeplayers")
          .getDocuments();
      qSnap.documents.forEach((DocumentSnapshot doc) {
        if (doc.data["id"] != null) {
          firestoreInstance
              .collection("users/${doc.data["id"]}/tournamentresults")
              .add({
            "gamename": widget.game.name,
            "groupname": widget.group.name,
            "gametype": widget.game.gameType,
            "day": int.tryParse(widget.game.date.substring(0, 2)),
            "month": int.tryParse(widget.game.date.substring(3)),
            "time": widget.game.time,
            "year": int.tryParse(string),
            "profit": calculateProfits(
                doc.data["payout"], doc.data["rebuy"], doc.data["addon"]),
            "rebuy": doc.data["rebuy"],
            "buyin": widget.game.buyin,
            "addon": doc.data["addon"],
            "payout": doc.data["payout"],
            "placing": doc.data["placing"],
            "playeramount": qSnap.documents.length,
            "currency": widget.game.currency,
            "orderbytime": widget.game.orderByTime,
            "prizepool": widget.game.totalPrizePool,
            "public": widget.group.shareResults
          });
        }
      });
      return null;
    });
  }

  void moveGameToHistory() async {
    await saveResults();
    String historyPath =
        "groups/${widget.group.id}/games/type/tournamenthistory/${widget.game.id}";

    DocumentReference fromDocument =
        firestoreInstance.document(pathToTournament);
    DocumentReference toDocument = firestoreInstance.document(historyPath);
    firestoreInstance.runTransaction((Transaction tx) async {
      DocumentSnapshot documentsnapshot = await fromDocument.get();
      toDocument.setData(documentsnapshot.data);
    });

    firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot collectionSnapshotPlayers =
          await fromCollectionPlayers.getDocuments();
      collectionSnapshotPlayers.documents.forEach((DocumentSnapshot doc) {
        DocumentReference toCollection = firestoreInstance
            .document("$historyPath/players/${doc.documentID}");
        toCollection.setData(doc.data);
      });
      Delete().deleteCollection("$pathToTournament/players", 5);
      Delete().deleteCollection("$pathToTournament/activeplayers", 5);
    });

    firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot collectionSnapshotPosts =
          await fromCollectionPosts.getDocuments();
      collectionSnapshotPosts.documents.forEach((DocumentSnapshot doc) {
        CollectionReference toCollection =
            firestoreInstance.collection("$historyPath/posts");
        toCollection.add(doc.data);
      });
      Delete().deleteCollection("$pathToTournament/posts", 5);
    });

    firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot collectionSnapshotLog =
          await fromCollectionLog.getDocuments();
      collectionSnapshotLog.documents.forEach((DocumentSnapshot doc) {
        CollectionReference toCollection =
            firestoreInstance.collection("$historyPath/log");
        toCollection.add(doc.data);
      });
      Delete().deleteCollection("$pathToTournament/log", 5);
      firestoreInstance.document(pathToTournament).delete();
      Navigator.of(context)..pop()..pop();
    });
  }

  Widget _buildStreamOfLog(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      dense: true,
      title: new Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(
            "${document.data["title"]} ",
            style: new TextStyle(color: UIData.blue, fontSize: 20.0),
            overflow: TextOverflow.ellipsis,
          ),
          new Text(
            "${document.data["dayofweek"]} ${document.data["time"]} ${document.data["date"]}",
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(color: Colors.grey[600]),
          )
        ],
      ),
      contentPadding: EdgeInsets.all(10.0),
      subtitle: new Text(
        "${document.data["logbody"]}",
        // overflow: TextOverflow.ellipsis,
        style: new TextStyle(
            color: UIData.blackOrWhite,
            fontSize: UIData.fontSize16,
            letterSpacing: .50),
      ),
    );
  }

  Widget streamOfLog() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("$pathToTournament/log")
            .orderBy("orderbytime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return loading();
          else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  _buildStreamOfLog(context, snapshot.data.documents[index]),
            );
          }
        });
  }

  void _deleteAlert() {
    AlertDialog dialog = new AlertDialog(
      title: new Text(
        "Are you sure you want to delete this game?",
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.all(20.0),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              isLoading = true;
            });
            await Delete().deleteGame(pathToTournament, false);
            Navigator.of(context)..pop()..pop();
          },
          child: new Text(
            "Yes",
            textAlign: TextAlign.left,
          ),
        ),
        new FlatButton(
          onPressed: () =>
              Navigator.canPop(context) ? Navigator.pop(context) : null,
          child: new Text(
            "Cancel",
            style: new TextStyle(color: UIData.red),
          ),
        ),
      ],
    );
    showDialog(context: context, child: dialog);
  }

  _finishedAlert() {
    AlertDialog dialog = new AlertDialog(
      title: new Text(
        "Have you made sure results are correct? The game will be moved to history.",
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.all(20.0),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              isLoading = true;
            });
            Log().postLogToCollection(
                "$currentUserName marked game as finished",
                "$pathToTournament/log",
                "Finished");
            moveGameToHistory();
          },
          child: new Text(
            "Yes",
            textAlign: TextAlign.left,
          ),
        ),
        new FlatButton(
          onPressed: () => Navigator.pop(context, false),
          child: new Text("Cancel"),
        ),
      ],
    );
    showDialog(context: context, child: dialog);
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: new DateTime(_date.year),
      lastDate: new DateTime(_date.year + 1),
    );

    if (picked != null) {
      debugPrint("Date selected : ${_date.toString()}");
      setState(() {
        String _gameDate;
        _date = picked;
        String month = _date.month.toString();
        String day = _date.day.toString();
        month.length == 1 ? month = "0" + _date.month.toString() : null;
        day.length == 1 ? day = "0" + _date.day.toString() : null;
        _gameDate = day + "/" + month;

        widget.game.setDate(_gameDate);
      });
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null) {
      print("Time selected ${_time.toString()}");
      setState(() {
        String _gameTime;
        _time = picked;
        String hour = _time.hour.toString();
        String minute = _time.minute.toString();
        hour.length == 1 ? hour = "0" + _time.hour.toString() : null;
        minute.length == 1 ? minute = "0" + _time.minute.toString() : null;
        _gameTime = hour + ":" + minute;

        widget.game.setTime(_gameTime);
      });
    }
  }
}
