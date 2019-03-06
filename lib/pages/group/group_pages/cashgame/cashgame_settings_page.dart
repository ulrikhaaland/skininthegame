import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/group/group_pages/tournament/tournamentPages/tournament_createplayer_page.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/objects/game.dart';
import 'package:yadda/utils/delete.dart';
import 'package:yadda/auth.dart';
import 'package:yadda/utils/layout.dart';
import 'package:yadda/pages/inAppPurchase/subscription.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CashGameSettingsPage extends StatefulWidget {
  CashGameSettingsPage(
      {Key key,
      this.group,
      this.user,
      this.callBack,
      this.history,
      this.auth,
      this.game,
      this.updateState,
      this.moneyInPlay})
      : super(key: key);
  final BaseAuth auth;
  final Group group;
  final User user;
  final Game game;
  final VoidCallback callBack;
  final VoidCallback updateState;
  final VoidCallback moneyInPlay;

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

  List<User> adminsList = new List();
  String floorName;

  // New game

  IconData regIcon;
  String regText;

  bool isLoading = false;

  CollectionReference fromCollectionPlayers;
  CollectionReference fromCollectionPosts;
  CollectionReference fromCollectionLog;
  CollectionReference fromCollectionPayouts;

  String pathToCashGame;
  String cashgameActiveOrHistory = "cashgameactive";

  DateTime _date;
  TimeOfDay _time;

  initState() {
    super.initState();
    adminsList.add(widget.user);
    getAdmins();
    _tabController = new TabController(vsync: this, length: 2);
    currentUserId = widget.user.id;
    currentUserName = widget.user.userName;
    groupId = widget.group.id;
    setReg();
    if (widget.history == true) {
      cashgameActiveOrHistory = "cashgamehistory";
    }
    _date = new DateTime(
        int.tryParse(widget.game.orderByTime.toString().substring(0, 4)),
        int.tryParse(widget.game.orderByTime.toString().substring(4, 6)),
        int.tryParse(widget.game.orderByTime.toString().substring(6, 8)));
    _time = new TimeOfDay(
        hour: int.tryParse(widget.game.orderByTime.toString().substring(8, 10)),
        minute:
            int.tryParse(widget.game.orderByTime.toString().substring(10, 12)));

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

  void setReg() {
    if (widget.game.stopReg) {
      regIcon = Icons.lock_open;
      regText = "Open Registrations";
    } else {
      regIcon = Icons.lock_outline;
      regText = "Close Registrations";
    }
  }

  void getAdmins() async {
    QuerySnapshot qSnap = await firestoreInstance
        .collection("groups/${widget.group.id}/members")
        .getDocuments();
    adminsList.removeAt(0);
    qSnap.documents.forEach((doc) {
      if (doc.data["admin"]) {
        adminsList.add(new User(
            null,
            doc.data["uid"],
            doc.data["username"],
            doc.data["fcm"],
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null));
      }
    });
    setState(() {});
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
                        Layout().dividerPadded(),
                        markAsFinishedList(),
                        Layout().dividerPadded(),
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
                        Layout().dividerPadded(),
                        showReg(),
                        Layout().dividerPadded(),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                        ),
                        Layout().padded(
                          child: new TextFormField(
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
                        ),
                        Layout().padded(
                          child: new TextFormField(
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
                        Layout().padded(
                          child: new TextFormField(
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
                                int isNumber = int.tryParse(val);
                                if (isNumber != null) {
                                  val.isEmpty
                                      ? val = widget.game.maxPlayers.toString()
                                      : null;

                                  if (widget.user.subLevel < 2) {
                                    String sub;
                                    if (widget.user.subLevel == 1 &&
                                        int.tryParse(val) > 9) {
                                      sub =
                                          "Your current subscription only allows \n9 players per cash game";
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Subscription(
                                                    user: widget.user,
                                                    info: true,
                                                    title: sub,
                                                  )));
                                      return sub;
                                    } else if (widget.user.subLevel == 0 &&
                                        int.tryParse(val) > 6) {
                                      sub =
                                          "Your current subscription only allows \n6 players per cash game";
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Subscription(
                                                    user: widget.user,
                                                    info: true,
                                                    title: sub,
                                                  )));
                                      return sub;
                                    }
                                  }
                                } else {
                                  return "Input must be a number!";
                                }
                              },
                              onSaved: (val) {
                                if (val.isEmpty) {
                                  switch (widget.user.subLevel) {
                                    case (0):
                                      widget.game.setMaxPlayers(6);
                                      break;
                                    case (1):
                                      widget.game.setMaxPlayers(9);
                                      break;
                                    case (2):
                                      widget.game.setMaxPlayers(9);
                                      break;
                                  }
                                } else if (widget.user.subLevel == 1 &&
                                    int.tryParse(val) > 9) {
                                  widget.game.setMaxPlayers(9);
                                } else if (widget.user.subLevel == 0 &&
                                    int.tryParse(val) > 6) {
                                  widget.game.setMaxPlayers(6);
                                } else {
                                  widget.game.setMaxPlayers(int.tryParse(val));
                                }
                              }),
                        ),
                        Layout().padded(
                          child: new TextFormField(
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
                                  validator: (val) {
                                    int isNumber = int.tryParse(val);
                                    if (isNumber == null) {
                                      return "Input must be a number!";
                                    }
                                  },
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
                                    validator: (val) {
                                      int isNumber = int.tryParse(val);
                                      if (isNumber == null) {
                                        return "Input must be a number!";
                                      }
                                    },
                                    onSaved: (val) => widget.game
                                        .setBBlind(int.tryParse(val))),
                              ),
                            ),
                          ],
                        ),
                        Layout().padded(
                          child: new TextFormField(
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
                                  ? widget.game
                                      .setCurrency(widget.user.currency)
                                  : widget.game.setCurrency(val)),
                        ),
                        Layout().padded(
                          child: new TextFormField(
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
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            subtitle: new Text(
                              "The user in charge of this game",
                              style: new TextStyle(color: Colors.grey[600]),
                            ),
                            title: new Text(
                              "Floor",
                              style: new TextStyle(color: UIData.blackOrWhite),
                            ),
                            trailing: Theme(
                              data: Theme.of(context)
                                  .copyWith(canvasColor: UIData.appBarColor),
                              child: new Container(
                                child: new DropdownButton<User>(
                                  style: TextStyle(color: UIData.blackOrWhite),
                                  hint: new Text(
                                    widget.game.floorName,
                                    style: new TextStyle(
                                        color: UIData.blackOrWhite,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  items: adminsList.map((User user) {
                                    return new DropdownMenuItem<User>(
                                      value: user,
                                      child: new Text(
                                        user.userName,
                                        style: new TextStyle(
                                            color: UIData.blackOrWhite),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (_) {
                                    if (widget.game.floorName != _.userName) {
                                      setState(() {
                                        widget.game.floorName = _.userName;
                                        for (var user in adminsList) {
                                          if (user.userName == _.userName) {
                                            widget.game.floor = user.id;
                                            widget.game.floorFCM = user.fcm;
                                            widget.game.floorName =
                                                user.userName;
                                          }
                                        }
                                      });
                                      firestoreInstance
                                          .document(pathToCashGame)
                                          .updateData({
                                        "floor": widget.game.floor,
                                        "floorfcm": widget.game.floorFCM,
                                        "floorname": widget.game.floorName,
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        new CheckboxListTile(
                            subtitle: new Text(
                              "Let users see how much money is on the table",
                              style: new TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            title: new Text(
                              "Money on the table",
                              style: new TextStyle(color: UIData.blackOrWhite),
                            ),
                            value: widget.game.showMoneyOnTable,
                            onChanged: (val) {
                              if (widget.user.subLevel == 0) {
                                showDisabledMoneyOnTheTable = true;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Subscription(
                                              user: widget.user,
                                              info: true,
                                              title:
                                                  "Your current subscription does not include showing money on the table",
                                            )));
                              } else {
                                widget.game.showMoneyOnTable = val;
                                setState(() {});
                              }
                            }),
                        disabledMoneyOnTheTable(),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
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

  bool showDisabledMoneyOnTheTable = false;
  Widget disabledMoneyOnTheTable() {
    if (showDisabledMoneyOnTheTable) {
      return new Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Text(
            "Your current subscription does not include showing money on the table",
            style: new TextStyle(color: Colors.red),
          ));
    } else {
      return new Container();
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget showReg() {
    if (!widget.history) {
      return new ListTile(
        leading: new Icon(
          regIcon,
          size: 40.0,
          color: UIData.yellow,
        ),
        title: new Text(
          regText,
          style: new TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
        ),
        onTap: () async {
          String regType;
          widget.game.stopReg = !widget.game.stopReg;
          widget.game.stopReg ? regType = "closed" : regType = "opened";
          setState(() {
            setReg();
          });
          firestoreInstance.document(pathToCashGame).updateData({
            "stopreg": widget.game.stopReg,
          });
          Log().postLogToCollection(
              "${widget.user.userName} has $regType registrations",
              "$pathToCashGame/log",
              "Registration");
        },
      );
    } else {
      return new Container();
    }
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
      widget.game.pushGameToFirestore(pathToCashGame, true);

      Log().postLogToCollection(
          "$currentUserName updated game. Name: ${widget.game.name}, Adress: ${widget.game.adress}, Date: ${widget.game.date}, Time: ${widget.game.time}, Maxplayers: ${widget.game.maxPlayers}, Buyin: ${widget.game.buyin} Rebuys: ${widget.game.rebuy}, Addon: ${widget.game.addon}, Starting chips: ${widget.game.startingChips}, Prize pool: ${widget.game.totalPrizePool} Gametype: ${widget.game.gameType}, Gameinfo: ${widget.game.info}",
          "$pathToCashGame/log",
          "Update");
      Essentials()
          .showSnackBar("Game has been updated", formKey.currentState.context);
    }
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
          "Start Game",
          style: new TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
        ),
        onTap: () {
          widget.moneyInPlay();
          firestoreInstance.document(pathToCashGame).updateData({
            "isrunning": true,
          });

          setState(() {
            widget.game.isRunning = true;
          });
          Essentials()
              .showSnackBar("Game has started!", formKey.currentState.context);
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
          "End Game",
          style: new TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
        ),
        onTap: () {
          _finishedAlert();
        },
      );
    } else {
      return new Container();
    }
  }

  int calculateProfits(int payout, int buyin) {
    if (payout != null) {
      payout -= buyin;
    }
    return payout;
  }

  Future<Null> saveResults() async {
    String string = widget.game.orderByTime.toString();
    string = string.substring(0, 4);
    string == "null" ? string = DateTime.now().year.toString() : null;
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
          "share": widget.group.shareResults,
          "type": 0,
        });
      }
    });
    return null;
  }

  moveGameToHistory() async {
    await saveResults();
    String historyPath =
        "groups/${widget.group.id}/games/type/cashgamehistory/${widget.game.id}";

    DocumentReference fromDocument = firestoreInstance.document(pathToCashGame);
    DocumentReference toDocument = firestoreInstance.document(historyPath);
    await firestoreInstance.runTransaction((Transaction tx) async {
      DocumentSnapshot documentsnapshot = await fromDocument.get();
      await toDocument.setData(documentsnapshot.data);
    });

    QuerySnapshot collectionSnapshotPlayers =
        await fromCollectionPlayers.getDocuments();
    collectionSnapshotPlayers.documents.forEach((DocumentSnapshot doc) async {
      DocumentReference toCollection =
          firestoreInstance.document("$historyPath/players/${doc.documentID}");
      await toCollection.setData(doc.data);
    });

    QuerySnapshot collectionSnapshotPosts =
        await fromCollectionPosts.getDocuments();
    collectionSnapshotPosts.documents.forEach((DocumentSnapshot doc) async {
      CollectionReference toCollection =
          firestoreInstance.collection("$historyPath/posts");
      await toCollection.add(doc.data);
    });

    QuerySnapshot collectionSnapshotPayouts =
        await fromCollectionPayouts.getDocuments();
    collectionSnapshotPayouts.documents.forEach((DocumentSnapshot doc) async {
      CollectionReference toCollection =
          firestoreInstance.collection("$historyPath/payouts");
      await toCollection.add(doc.data);
    });

    QuerySnapshot collectionSnapshotLog =
        await fromCollectionLog.getDocuments();
    collectionSnapshotLog.documents.forEach((DocumentSnapshot doc) async {
      CollectionReference toCollection =
          firestoreInstance.collection("$historyPath/log");
      await toCollection.add(doc.data);
    });

    await CloudFunctions.instance
        .call(functionName: 'recursiveDelete', parameters: {
      "path": pathToCashGame,
    });
    Navigator.of(context)..pop()..pop();
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
            await CloudFunctions.instance
                .call(functionName: 'recursiveDelete', parameters: {
              "path": pathToCashGame,
            });
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
            moveGameToHistory();
            Log().postLogToCollection("$currentUserName ended the game",
                "$pathToCashGame/log", "Finished");
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
