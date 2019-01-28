import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/pages/group/group_pages/cashgame/group_page_cash_page.dart';
import 'dart:async';
import 'package:yadda/utils/uidata.dart';
import 'dart:math';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/objects/game.dart';
import 'package:yadda/utils/layout.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:yadda/utils/cloudFunctions.dart';
import 'package:yadda/pages/inAppPurchase/subscription.dart';

class NewCashGame extends StatefulWidget {
  NewCashGame({Key key, this.user, this.group, this.fromCashGamePage})
      : super(key: key);
  final User user;
  final Group group;
  final bool fromCashGamePage;

  @override
  NewCashGameState createState() => NewCashGameState();
}

enum FormType { public, private }

class NewCashGameState extends State<NewCashGame> {
  static final formKey = new GlobalKey<FormState>();
  final Firestore firestoreInstance = Firestore.instance;

  String currentUserId;
  String groupId;
  Game game;

  bool isLoading = false;

  bool notifyMembers = false;

  int gameId;

  String time = "";
  String date = "";

  bool gameIdAvailable = false;

  initState() {
    super.initState();
    currentUserId = widget.user.id;
    groupId = widget.group.id;
    game = new Game("", 0, null, "", "", "", "", 0, 0, "", "No Limit Hold'em",
        6, 0, 0, 0, 0, "", "", false, "USD", false, 0);
    game.setDate("Not set");
    game.setTime("Not set");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: UIData.dark,
      appBar: new AppBar(
        iconTheme: IconThemeData(color: UIData.blackOrWhite),
        actions: <Widget>[
          new FlatButton(
            child: new Text(
              "Create",
              style: new TextStyle(
                  fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              setGameId();
            },
          ),
        ],
        backgroundColor: UIData.appBarColor,
        title: new Text(
          "New Cash Game",
          style: new TextStyle(
              color: UIData.blackOrWhite, fontSize: UIData.fontSize24),
        ),
      ),
      body: new Stack(
        children: <Widget>[
          new Form(
            key: formKey,
            child: page(),
          ),
          Essentials().loading(isLoading),
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
    isLoading = false;
    return false;
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  void setGameId() {
    try {
      var random = new Random().nextInt(999999999);
      gameId = random;
      checkGameId();
      // _activeGames();
    } catch (e) {
      setState(() {
        print(e);
      });
      print(e);
    }
  }

  void checkGameId() async {
    firestoreInstance
        .collection("games/type/tournament")
        .where("gameid", isEqualTo: gameId)
        .getDocuments()
        .then((string) {
      if (string.documents.isEmpty) {
        setState(() {
          debugPrint("true");
          gameIdAvailable = true;
          _saveGame();
        });
      } else {
        setState(() {
          debugPrint("false");
          gameIdAvailable = false;
          setGameId();
        });
      }
    });
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
      game.setOrderByTime(int.tryParse(orderByTime));

      if (game.date == "Not set") {
        game.date = day + "/" + month;
      }
      if (game.time == "Not set") {
        game.time = hour + ":" + minute;
      }
      game.setId(gameId);
      game.pushGameToFirestore(
          "groups/$groupId/games/type/cashgameactive/$gameId", false);
      setState(() {
        isLoading = true;
      });
      Navigator.of(context)
        ..pop()
        ..pop()
        ..push(MaterialPageRoute(
            builder: (context) => GroupCashGames(
                  user: widget.user,
                  group: widget.group,
                )));

      if (notifyMembers == true) {
        CloudFunctions().groupNotification(game.name, widget.group.name,
            widget.group.id, game.id, "Cash Game!", widget.group);
      }
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

  Widget page() {
    return new SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Layout().padded(
              child: new TextFormField(
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: new TextStyle(color: UIData.blackOrWhite),
            key: new Key('name'),
            decoration: new InputDecoration(
                labelText: 'Name',
                labelStyle: new TextStyle(color: Colors.grey[600])),
            autocorrect: false,
            onSaved: (val) {
              if (val.isEmpty) {
                val = "Not Set";
              }
              if (val.length > 18) {
                String fittedString = val.substring(0, 16);
                game.setName(val);
                game.setFittedName("$fittedString...");
              } else {
                game.setName(val);
                game.setFittedName(val);
              }
            },
          )),
          Layout().padded(
              child: new TextFormField(
            textCapitalization: TextCapitalization.sentences,
            style: new TextStyle(color: UIData.blackOrWhite),
            key: new Key('adress'),
            decoration: new InputDecoration(
                labelText: 'Adress',
                labelStyle: new TextStyle(color: Colors.grey[600])),
            autocorrect: false,
            onSaved: (val) =>
                val.isEmpty ? game.setAdress("Not set") : game.setAdress(val),
          )),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              paddedTwo(
                child: new ConstrainedBox(
                  constraints:
                      BoxConstraints.expand(height: 40.0, width: 120.0),
                  child: new RaisedButton(
                      child: new Text("Date",
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: UIData.fontSize16,
                          )),
                      shape: new RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      color: Colors.yellow[700],
                      textColor: Colors.white,
                      onPressed: () {
                        _selectDate(context);
                      }),
                ),
              ),
              paddedTwo(
                child: new ConstrainedBox(
                  constraints:
                      BoxConstraints.expand(height: 40.0, width: 120.0),
                  child: new RaisedButton(
                      child: new Text("Time",
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: UIData.fontSize16,
                          )),
                      shape: new RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
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
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: new TextStyle(color: UIData.blackOrWhite),
                  key: new Key('maximumplayers'),
                  decoration: new InputDecoration(
                      hintText: game.maxPlayers.toString(),
                      labelText: 'Maximum players',
                      labelStyle: new TextStyle(color: Colors.grey[600])),
                  autocorrect: false,
                  validator: (val) {
                    val.isEmpty ? val = game.maxPlayers.toString() : null;
                    if (widget.user.subLevel < 2) {
                      String sub;
                      if (widget.user.subLevel == 1 && int.tryParse(val) > 9) {
                        sub =
                            "Your current subscription only allows \n9 players per cash game";
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
                          int.tryParse(val) > 6) {
                        sub =
                            "Your current subscription only allows \n6 players per cash game";
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
                          game.setMaxPlayers(6);
                          break;
                        case (1):
                          game.setMaxPlayers(9);
                          break;
                        case (2):
                          game.setMaxPlayers(9);
                          break;
                      }
                    } else if (widget.user.subLevel == 1 &&
                        int.tryParse(val) > 9) {
                      game.setMaxPlayers(9);
                    } else if (widget.user.subLevel == 0 &&
                        int.tryParse(val) > 6) {
                      game.setMaxPlayers(6);
                    } else {
                      game.setMaxPlayers(int.tryParse(val));
                    }
                  })),
          Layout().padded(
              child: new TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  style: new TextStyle(color: UIData.blackOrWhite),
                  key: new Key('gametype'),
                  decoration: new InputDecoration(
                      hintText: game.gameType,
                      labelText: 'Gametype',
                      labelStyle: new TextStyle(color: Colors.grey[600])),
                  autocorrect: false,
                  onSaved: (val) => val.isEmpty
                      ? game.setGameType("No Limit Hold'em")
                      : game.setGameType(val))),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              paddedTwo(
                child: new Container(
                  width: 120.0,
                  child: new TextFormField(
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardAppearance: Brightness.dark,
                    style: new TextStyle(color: UIData.blackOrWhite),
                    key: new Key('sblind'),
                    decoration: new InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Small Blind",
                        labelStyle: new TextStyle(color: Colors.grey[600])),
                    autocorrect: false,
                    onSaved: (val) => val.isEmpty
                        ? game.setSBlind(0)
                        : game.setSBlind(int.tryParse(val)),
                  ),
                ),
              ),
              paddedTwo(
                child: new Container(
                  width: 120.0,
                  child: new TextFormField(
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      keyboardAppearance: Brightness.dark,
                      style: new TextStyle(color: UIData.blackOrWhite),
                      key: new Key('bblind'),
                      decoration: new InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Big Blind",
                          labelStyle: new TextStyle(
                            color: Colors.grey[600],
                          )),
                      autocorrect: false,
                      onSaved: (val) => val.isEmpty
                          ? game.setBBlind(0)
                          : game.setBBlind(int.tryParse(val))),
                ),
              ),
            ],
          ),
          Layout().padded(
              child: new TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  style: new TextStyle(color: UIData.blackOrWhite),
                  key: new Key('currency'),
                  decoration: new InputDecoration(
                      hintText: game.currency,
                      labelText: 'Payout currency',
                      labelStyle: new TextStyle(color: Colors.grey[600])),
                  autocorrect: false,
                  onSaved: (val) => val.isEmpty
                      ? game.setCurrency("USD")
                      : game.setCurrency(val))),
          Layout().padded(
              child: new TextFormField(
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            style: new TextStyle(color: UIData.blackOrWhite),
            key: new Key('info'),
            decoration: new InputDecoration(
                labelText: 'Additional information',
                labelStyle: new TextStyle(color: Colors.grey[600])),
            autocorrect: false,
            onSaved: (val) =>
                val.isEmpty ? game.setInfo("Not Set") : game.setInfo(val),
          )),
          disabledNotifications(),
          Padding(
            padding: EdgeInsets.only(
              left: 4.0,
              right: 4.0,
            ),
            child: new CheckboxListTile(
                subtitle: new Text(
                  "Send a notification to members of the group",
                  style: new TextStyle(color: Colors.grey[600]),
                ),
                title: new Text(
                  "Notify members?",
                  style: new TextStyle(color: UIData.blackOrWhite),
                ),
                value: notifyMembers,
                onChanged: (val) {
                  if (widget.user.subLevel == 0) {
                    showDisabledNotifications = true;
                  } else {
                    notifyMembers = val;
                  }
                  setState(() {});
                }),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
          ),
          Padding(
            padding: EdgeInsets.only(left: 4.0, right: 4.0, bottom: 18.0),
            child: new CheckboxListTile(
                subtitle: new Text(
                  "Once the game is marked as finished, the app will calculate who pays who",
                  style: new TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                title: new Text(
                  "Calculate payouts",
                  style: new TextStyle(color: UIData.blackOrWhite),
                ),
                value: game.calculatePayouts,
                onChanged: (val) {
                  game.setCalculatePayouts(val);
                  setState(() {});
                }),
          ),
        ],
      ),
    );
  }

  bool showDisabledNotifications = false;
  Widget disabledNotifications() {
    if (showDisabledNotifications) {
      return new Padding(
          padding: EdgeInsets.all(18.0),
          child: Text(
            "Your current subscription does not include notifications",
            style: new TextStyle(color: Colors.red),
          ));
    } else {
      return new Container();
    }
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
        String month = _date.month.toString();
        String day = _date.day.toString();
        month.length == 1 ? month = "0" + _date.month.toString() : null;
        day.length == 1 ? day = "0" + _date.day.toString() : null;
        _gameDate = day + "/" + month;

        game.setDate(_gameDate);
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

        game.setTime(_gameTime);
      });
    }
  }
}
