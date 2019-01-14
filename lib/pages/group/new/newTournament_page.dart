import 'package:flutter/material.dart';
import 'package:yadda/objects/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:yadda/pages/group/group_pages/tournament/tournamentPages/group_page_tournaments_page.dart';
import 'package:yadda/utils/uidata.dart';
import 'dart:math';
import 'package:yadda/objects/group.dart';
import 'package:yadda/objects/game.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:yadda/utils/layout.dart';
import 'package:yadda/utils/cloudFunctions.dart';

class NewTournament extends StatefulWidget {
  NewTournament({Key key, this.user, this.group, this.fromTournamentGroupPage})
      : super(key: key);

  final User user;
  final Group group;
  final bool fromTournamentGroupPage;

  @override
  NewTournamentState createState() => NewTournamentState();
}

enum FormType { public, private }

class NewTournamentState extends State<NewTournament> {
  static final formKey = new GlobalKey<FormState>();
  final Firestore firestoreInstance = Firestore.instance;

  String currentUserId;
  String groupId;

  String date = "";
  String time = "";

  // New game

  int gameId;

  bool gameIdAvailable = false;

  bool isLoading = false;

  bool notifyMembers = false;

  Game game;

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
          title: new Text("New Tournament",
              style: new TextStyle(
                  fontSize: UIData.fontSize24, color: UIData.blackOrWhite))),
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

  initState() {
    super.initState();
    currentUserId = widget.user.id;
    groupId = widget.group.id;

    game = new Game("", 0, null, "", "", "", "", 0, 0, "", "No Limit Hold'em",
        18, 0, 0, 0, 0, "", "", false, "USD", false);
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
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
    firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot qSnap = await firestoreInstance
          .collection("games/type/tournamentactive")
          .where("gameid", isEqualTo: gameId)
          .getDocuments();
      if (qSnap.documents.isEmpty) {
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
      String orderByTime = "$date$time";
      game.setOrderByTime(int.tryParse(orderByTime));
      if (game.getOrderByTime() == null) {
        game.setOrderByTime(0);
      }
      game.setId(gameId);
      game.pushGameToFirestore(
          "groups/$groupId/games/type/tournamentactive/$gameId", false);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context)
        ..pop()
        ..pop()
        ..push(MaterialPageRoute(
            builder: (context) => GroupTournaments(
                  user: widget.user,
                  group: widget.group,
                )));

      if (notifyMembers == true) {
        CloudFunctions().groupNotification(game.name, widget.group.name,
            widget.group.id, game.id, "Tournament!", widget.group);
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
              initialValue: "${game.getName()}",
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
            ),
          ),
          padded(
              child: new TextFormField(
            textCapitalization: TextCapitalization.sentences,
            style: new TextStyle(color: UIData.blackOrWhite),
            key: new Key('adress'),
            decoration: new InputDecoration(
                labelText: 'Adress',
                labelStyle: new TextStyle(color: Colors.grey[600])),
            autocorrect: false,
            onSaved: (val) =>
                val.isEmpty ? game.setAdress("Not Set") : game.setAdress(val),
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
          Padding(
              padding: EdgeInsets.only(left: 18.0, right: 18.0),
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
                  onSaved: (val) => val.isEmpty
                      ? game.setMaxPlayers(18)
                      : game.setMaxPlayers(int.tryParse(val)))),
          padded(
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
          new Column(
            children: <Widget>[
              padded(
                  child: new TextFormField(
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      style: new TextStyle(color: UIData.blackOrWhite),
                      key: new Key('buyin'),
                      decoration: new InputDecoration(
                          labelText: 'Buyin',
                          labelStyle: new TextStyle(color: Colors.grey[600])),
                      autocorrect: false,
                      onSaved: (val) => val.isEmpty
                          ? game.setBuyin(0)
                          : game.setBuyin(int.tryParse(val)))),
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                width: 120.0,
                child: new TextFormField(
                  keyboardType: TextInputType.number,
                  keyboardAppearance: Brightness.dark,
                  style: new TextStyle(color: UIData.blackOrWhite),
                  key: new Key('rebuy'),
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Rebuy",
                      labelStyle: new TextStyle(color: Colors.grey[600])),
                  autocorrect: false,
                  onSaved: (val) => val.isEmpty
                      ? game.setRebuy(0)
                      : game.setRebuy(int.tryParse(val)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
              ),
              new Container(
                width: 120.0,
                child: new TextFormField(
                    keyboardType: TextInputType.number,
                    keyboardAppearance: Brightness.dark,
                    style: new TextStyle(color: UIData.blackOrWhite),
                    key: new Key('addon'),
                    decoration: new InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Addon",
                        labelStyle: new TextStyle(color: Colors.grey[600])),
                    autocorrect: false,
                    onSaved: (val) => val.isEmpty
                        ? game.setAddon(0)
                        : game.setAddon(int.tryParse(val))),
              ),
            ],
          ),
          padded(
              child: new TextFormField(
            keyboardType: TextInputType.number,
            style: new TextStyle(color: UIData.blackOrWhite),
            key: new Key('startingchips'),
            decoration: new InputDecoration(
                labelText: 'Starting chips',
                labelStyle: new TextStyle(color: Colors.grey[600])),
            autocorrect: false,
            onSaved: (val) => val.isEmpty
                ? game.setStartingChips("0")
                : game.setStartingChips(val),
          )),
          padded(
              child: new TextFormField(
            style: new TextStyle(color: UIData.blackOrWhite),
            key: new Key('totalprizepool'),
            decoration: new InputDecoration(
                labelText: 'Total prize pool',
                labelStyle: new TextStyle(color: Colors.grey[600])),
            autocorrect: false,
            onSaved: (val) => val.isEmpty
                ? game.setTotalPrizePool("Not Set")
                : game.setTotalPrizePool(val),
          )),
          padded(
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
          padded(
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
                val.isEmpty ? game.setInfo("No info") : game.setInfo(val),
          )),
          Padding(
            padding: EdgeInsets.only(left: 4.0, right: 4.0, bottom: 18.0),
            child: new CheckboxListTile(
                title: new Text(
                  "Notify members?",
                  style: new TextStyle(color: UIData.blackOrWhite),
                ),
                subtitle: new Text(
                  "Send a notification to members of the group",
                  style: new TextStyle(color: Colors.grey[600]),
                ),
                value: notifyMembers,
                onChanged: (val) {
                  if (val == true) {
                    notifyMembers = true;
                  } else {
                    notifyMembers = false;
                  }
                  setState(() {});
                }),
          ),
        ],
      ),
    );
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
        _gameTime = _time.toString();
        List parts = _gameTime.split("y");
        List parts1 = parts[1].split("(");
        List parts2 = parts1[1].split(")");
        time = parts2[0];
        time = time.replaceAll(":", "");
        _gameTime = "${parts2[0]}";
        game.setTime(_gameTime);
      });
    }
  }
}
