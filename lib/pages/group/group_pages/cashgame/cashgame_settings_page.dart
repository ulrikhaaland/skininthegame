import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/group/group_pages/tournament/tournamentPages/tournament_createplayer_page.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/objects/game.dart';
import 'package:yadda/utils/delete.dart';
import 'package:yadda/pages/bottomNavigation/first_tab/bottom_nav.dart';
import 'package:yadda/auth.dart';
import 'package:yadda/utils/layout.dart';

class CashGameSettingsPage extends StatefulWidget {
  CashGameSettingsPage({
    Key key,
    this.group,
    this.user,
    this.callBack,
    this.history,
    this.auth,
    this.game,
  }) : super(key: key);
  final BaseAuth auth;
  final Group group;
  final User user;
  final Game game;
  final VoidCallback callBack;
  final bool history;
  @override
  CashGameSettingsPageState createState() => CashGameSettingsPageState();
}

class Person {
  Person(this.name, this.result, this.resultIsNegative, this.index);

  String name;
  int result;
  bool resultIsNegative;
  int index;

  setResultIsNegative(bool resultIsNegative) {
    this.resultIsNegative = resultIsNegative;
  }

  bool getResultIsNegative() {
    return this.resultIsNegative;
  }

  setIndex(int index) {
    this.index = index;
  }

  int getIndex() {
    return this.index;
  }

  setResult(int result) {
    this.result = result;
  }

  int getResult() {
    return this.result;
  }

  setName(String name) {
    this.name = name;
  }

  String getName() {
    return this.name;
  }
}

class CashGameSettingsPageState extends State<CashGameSettingsPage>
    with TickerProviderStateMixin {
  static final formKey = new GlobalKey<FormState>();

  TabController _tabController;

  Random random = new Random();

  final Firestore firestoreInstance = Firestore.instance;

  String currentUserId;
  String currentUserName;

  String groupId;

  String time;
  String date;

  // New game

  bool isLoading = false;

  CollectionReference fromCollectionPlayers;
  CollectionReference fromCollectionPosts;
  CollectionReference fromCollectionLog;
  CollectionReference fromCollectionPayouts;

  String pathToCashGame;
  String cashgameActiveOrHistory = "cashgameactive";

  initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    currentUserId = widget.user.id;
    currentUserName = widget.user.userName;
    groupId = widget.group.id;
    if (widget.history == true) {
      cashgameActiveOrHistory = "cashgamehistory";
    }
    pathToCashGame =
        "groups/$groupId/games/type/$cashgameActiveOrHistory/${widget.game.id}";

    fromCollectionPlayers =
        firestoreInstance.collection("$pathToCashGame/players");
    fromCollectionPosts = firestoreInstance.collection("$pathToCashGame/posts");
    fromCollectionLog = firestoreInstance.collection("$pathToCashGame/log");
    fromCollectionPayouts =
        firestoreInstance.collection("$pathToCashGame/payouts");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                size: 30,
              ),
              text: "Edit",
            ),
            Tab(
              icon: Icon(
                Icons.list,
                color: Colors.grey[600],
                size: 30,
              ),
              text: "Game Log",
            ),
          ],
        ),
      ),
      body: new Stack(
        children: <Widget>[
          Form(
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
                            "Create Player",
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
                                          fromCash: true,
                                        )));
                          },
                        ),
                        Layout().divider(),
                        markAsFinishedList(),
                        Layout().divider(),
                        new ListTile(
                          leading: new Icon(
                            Icons.delete,
                            size: 40.0,
                            color: UIData.red,
                          ),
                          title: new Text(
                            "Delete Game",
                            style: new TextStyle(
                                color: UIData.blackOrWhite,
                                fontSize: UIData.fontSize20),
                          ),
                          onTap: () async {
                            _deleteAlert();
                          },
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
                                    height: 40.0, width: 120.0),
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
                                    // textColor: Colors.white,
                                    onPressed: () {
                                      _selectDate(context);
                                    }),
                              ),
                            ),
                            paddedTwo(
                              child: new ConstrainedBox(
                                constraints: BoxConstraints.expand(
                                    height: 40.0, width: 120.0),
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
                          onSaved: (val) =>
                              widget.game.setMaxPlayers(int.tryParse(val)),
                        ),
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
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            paddedTwo(
                              child: new Container(
                                width: 120.0,
                                child: new TextFormField(
                                  maxLength: 4,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  initialValue: widget.game.sBlind.toString(),
                                  keyboardAppearance: Brightness.dark,
                                  style:
                                      new TextStyle(color: UIData.blackOrWhite),
                                  key: new Key('sblind'),
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Small Blind",
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[600])),
                                  autocorrect: false,
                                  onSaved: (val) =>
                                      widget.game.setSBlind(int.tryParse(val)),
                                ),
                              ),
                            ),
                            paddedTwo(
                              child: new Container(
                                width: 120.0,
                                child: new TextFormField(
                                    maxLength: 4,
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    initialValue: widget.game.bBlind.toString(),
                                    keyboardAppearance: Brightness.dark,
                                    style: new TextStyle(
                                        color: UIData.blackOrWhite),
                                    key: new Key('bblind'),
                                    decoration: new InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Big Blind",
                                        labelStyle: new TextStyle(
                                            color: Colors.grey[600])),
                                    autocorrect: false,
                                    onSaved: (val) => widget.game
                                        .setBBlind(int.tryParse(val))),
                              ),
                            ),
                          ],
                        ),
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
              )),
          loadingTwo(),
        ],
      ),
    );
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
      return new Center();
    }
  }

  void _saveGame() {
    if (validateAndSave()) {
      if (date == null) {
        date = widget.game.getDate().replaceAll("/", "");
        String d = widget.game.getOrderByTime().toString();
        date = "${d.replaceRange(4, d.length, "")}$date";
      }
      if (time == null) {
        time = widget.game.getTime().replaceAll(":", "");
        time = time.replaceAll("PM", "");
      }
      String orderByTime = "$date$time";
      widget.game.setOrderByTime(int.tryParse(orderByTime));
      widget.game.pushGameToFirestore(pathToCashGame, true);

      Log().postLogToCollection(
          "$currentUserName updated game. Name: ${widget.game.name}, Adress: ${widget.game.adress}, Date: ${widget.game.date}, Time: ${widget.game.time}, Maxplayers: ${widget.game.maxPlayers}, Buyin: ${widget.game.buyin} Rebuys: ${widget.game.rebuy}, Addon: ${widget.game.addon}, Starting chips: ${widget.game.startingChips}, Prize pool: ${widget.game.totalPrizePool} Gametype: ${widget.game.gameType}, Gameinfo: ${widget.game.info}",
          "$pathToCashGame/log",
          "Update");
    }
    showSnackBar("Game has been updated");
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
      child: child,
    );
  }

  Widget paddedTwo({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: child,
    );
  }

  Widget markAsFinishedList() {
    if (widget.history != true && !widget.game.isRunning) {
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
          firestoreInstance.document(pathToCashGame).updateData({
            "isrunning": true,
          });

          setState(() {
            widget.game.isRunning = true;
          });
          showSnackBar("Game has started!");
        },
      );
    } else if (widget.history != true && widget.game.isRunning) {
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
        onTap: () {
          _finishedAlert();
        },
      );
    } else {
      return new ListTile(
        leading: new Icon(
          Icons.attach_money,
          size: 40.0,
          color: UIData.green,
        ),
        title: new Text(
          "Calculate Payouts",
          style: new TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
        ),
        onTap: () async {
          QuerySnapshot qSnap = await firestoreInstance
              .collection("$pathToCashGame/payouts")
              .getDocuments();
          qSnap.documents.forEach((DocumentSnapshot doc) {
            firestoreInstance
                .document("$pathToCashGame/payouts/${doc.documentID}")
                .delete();
          });
          setState(() {
            isLoading = true;
          });
          calculatePayouts(true, false);
        },
      );
    }
  }

  showSnackBar(String message) {
    Scaffold.of(formKey.currentState.context).showSnackBar(new SnackBar(
      backgroundColor: UIData.yellow,
      content: new Text(
        message,
        textAlign: TextAlign.center,
        style: new TextStyle(color: Colors.black),
      ),
    ));
  }

  void calculatePayouts(bool calculate, bool moveGame) async {
    if (calculate == true) {
      List<Person> personList = new List();
      firestoreInstance.runTransaction((Transaction tx) async {
        QuerySnapshot qSnap = await firestoreInstance
            .collection("$pathToCashGame/players")
            .getDocuments();
        int q = 0;
        qSnap.documents.forEach((DocumentSnapshot doc) {
          String i = doc.data["payout"];
          int payout = int.tryParse(i);

          int buyin = doc.data["buyin"];
          int result = payout - buyin;
          bool isNegative;
          if (result.isNegative) {
            isNegative = true;
          } else {
            isNegative = false;
          }
          Person person = new Person(doc.data["name"], result, isNegative, q);
          personList.add(person);
          q++;
        });

        Person personNegative;
        Person personPositive;

        while (personList.isNotEmpty) {
          int n = 0;
          int p = 0;
          for (int i = 0; i < personList.length; i++) {
            if (personList[i].result.isNegative || personList[i].result == 0) {
              n++;
            }
            if (!personList[i].result.isNegative || personList[i].result == 0) {
              p++;
            }
          }
          if (n == personList.length) {
            for (int i = 0; i < personList.length;) {
              int z = personList[0].result.abs();
              if (personList[0].result != 0) {
                await firestoreInstance
                    .collection("$pathToCashGame/payouts")
                    .add({
                  "sentence": "${personList[0].name} has $z left to pay out.",
                  "personnegative": "",
                  "personpositive": "",
                  "result": "",
                });
              }

              personList.removeAt(i);
            }
            setState(() {
              isLoading = false;
            });
            showSnackBar(
              "Payouts has been updated",
            );
          } else if (p == personList.length) {
            for (int i = 0; i < personList.length;) {
              await firestoreInstance
                  .collection("$pathToCashGame/payouts")
                  .add({
                "sentence":
                    "${personList[0].name} is missing ${personList[0].result}.",
                "personnegative": "",
                "personpositive": "",
                "result": "",
              });
              personList.removeAt(i);
            }
            setState(() {
              isLoading = false;
            });
            showSnackBar(
              "Payouts has been updated",
            );
          }
          if (personList.length != 0) {
            int i = random.nextInt(personList.length);
            for (int i = 0; i < personList.length; i++) {
              personList[i].setIndex(i);
            }
            if (personNegative == null) {
              if (personList[i].resultIsNegative == true) {
                personNegative = personList[i];
              }
            }
            if (personPositive == null) {
              if (!personList[i].resultIsNegative == true &&
                  personList[i].result != 0) {
                personPositive = personList[i];
              }
            }
            if (personPositive != null && personNegative != null) {
              int pRes = personPositive.result;
              int nRes = personNegative.result;
              int fRes = nRes + pRes;
              if (fRes.isNegative) {
                personNegative.setResult(fRes);

                await firestoreInstance
                    .collection("$pathToCashGame/payouts")
                    .add({
                  "sentence":
                      "${personNegative.name} pays ${personPositive.name} ${personPositive.result}.",
                  "personnegative": personNegative.name,
                  "personpositive": personPositive.name,
                  "result": personPositive.result,
                });

                personList
                    .removeWhere((item) => item.name == personPositive.name);
                personPositive = null;
              } else if (fRes == 0) {
                personList
                    .removeWhere((item) => item.name == personPositive.name);
                personList
                    .removeWhere((item) => item.name == personNegative.name);
                await firestoreInstance
                    .collection("$pathToCashGame/payouts")
                    .add({
                  "sentence":
                      "${personNegative.name} pays ${personPositive.name} ${personPositive.result}.",
                  "personnegative": personNegative.name,
                  "personpositive": personPositive.name,
                  "result": personPositive.result,
                });

                personPositive = null;
                personNegative = null;
                setState(() {
                  isLoading = false;
                });
                showSnackBar(
                  "Payouts has been updated",
                );
              } else if (!fRes.isNegative) {
                personPositive.setResult(fRes);
                int abs = personNegative.result.abs();
                await firestoreInstance
                    .collection("$pathToCashGame/payouts")
                    .add({
                  "sentence":
                      "${personNegative.name} pays ${personPositive.name} $abs.",
                  "personnegative": personNegative.name,
                  "personpositive": personPositive.name,
                  "result": abs,
                });

                personList.remove(personList[personNegative.index]);

                personNegative = null;
              }
            }
          }
        }
        if (moveGame == true) {
          moveGameToHistory();
        }
      });
    } else if (moveGame == true) {
      moveGameToHistory();
    }
  }

  String calculateProfits(String payout, int buyin) {
    int p = int.tryParse(payout);
    String finalProfit;
    if (p != null) {
      p -= buyin;
      finalProfit = p.toString();
    } else {
      finalProfit = payout;
    }
    return finalProfit;
  }

  Future<Null> saveResults() async {
    String string = widget.game.orderByTime.toString();
    string = string.substring(0, 4);
    await firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot qSnap = await firestoreInstance
          .collection("$pathToCashGame/players")
          .getDocuments();
      qSnap.documents.forEach((DocumentSnapshot doc) {
        if (doc.data["id"] != null) {
          firestoreInstance
              .document(
                  "users/${doc.data["id"]}/cashgameresults/${widget.game.id}")
              .setData({
            "gamename": widget.game.name,
            "groupname": widget.group.name,
            "gametype": widget.game.gameType,
            "day": int.tryParse(widget.game.date.substring(0, 2)),
            "month": int.tryParse(widget.game.date.substring(3)),
            "time": widget.game.time,
            "year": int.tryParse(string),
            "profit": calculateProfits(doc.data["payout"], doc.data["buyin"]),
            "currency": widget.game.currency,
            "buyin": doc.data["buyin"],
            "payout": doc.data["payout"],
            "bblind": widget.game.bBlind,
            "sblind": widget.game.sBlind,
            "orderbytime": widget.game.orderByTime,
          });
        }
      });
      return null;
    });
  }

  moveGameToHistory() async {
    await saveResults();
    String historyPath =
        "groups/${widget.group.id}/games/type/cashgamehistory/${widget.game.id}";

    DocumentReference fromDocument = firestoreInstance.document(pathToCashGame);
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
      Delete().deleteCollection("$pathToCashGame/players", 5);
      Delete().deleteCollection("$pathToCashGame/activeplayers", 5);
    });

    firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot collectionSnapshotPosts =
          await fromCollectionPosts.getDocuments();
      collectionSnapshotPosts.documents.forEach((DocumentSnapshot doc) {
        CollectionReference toCollection =
            firestoreInstance.collection("$historyPath/posts");
        toCollection.add(doc.data);
      });
      Delete().deleteCollection("$pathToCashGame/posts", 5);
    });

    firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot collectionSnapshotPosts =
          await fromCollectionPayouts.getDocuments();
      collectionSnapshotPosts.documents.forEach((DocumentSnapshot doc) {
        CollectionReference toCollection =
            firestoreInstance.collection("$historyPath/payouts");
        toCollection.add(doc.data);
      });
      Delete().deleteCollection("$pathToCashGame/payouts", 5);
    });

    firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot collectionSnapshotLog =
          await fromCollectionLog.getDocuments();
      collectionSnapshotLog.documents.forEach((DocumentSnapshot doc) {
        CollectionReference toCollection =
            firestoreInstance.collection("$historyPath/log");
        toCollection.add(doc.data);
      });
      Delete().deleteCollection("$pathToCashGame/log", 5);
      firestoreInstance.document(pathToCashGame).delete();
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
            .collection("$pathToCashGame/log")
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
            Navigator.of(context).pop();
            setState(() {
              isLoading = true;
            });
            Delete().deleteGame(pathToCashGame, true);
            Navigator.of(context)..pop()..pop();
          },
          child: new Text(
            "Yes",
            textAlign: TextAlign.left,
          ),
        ),
        new FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: new Text("Cancel"),
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
            setState(() {
              isLoading = true;
            });
            calculatePayouts(widget.game.calculatePayouts, true);

            Log().postLogToCollection(
                "$currentUserName marked game as finished",
                "$pathToCashGame/log",
                "Finished");
            Navigator.of(context).pop();
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

  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();

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
        _gameDate = _date.toString();
        List parts = _gameDate.split(" ");

        _gameDate = parts[0];
        date = _gameDate.replaceAll("-", "");

        String parts2 = _gameDate.substring(5);
        _gameDate = parts2;

        List parts3 = _gameDate.split("-");
        _gameDate = "${parts3[1]}/${parts3[0]}";
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
        _gameTime = _time.toString();
        List parts = _gameTime.split("y");
        List parts1 = parts[1].split("(");
        List parts2 = parts1[1].split(")");
        time = parts2[0];
        time = time.replaceAll(":", "");
        _gameTime = "${parts2[0]}";
        widget.game.setTime(_gameTime);
      });
    }
  }
}
