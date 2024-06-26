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
// import 'package:yadda/pages/inAppPurchase/subscription.dart';

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

  String year = "";

  // New game

  int gameId;

  bool gameIdAvailable = false;
  bool sameAsBuyin = true;
  List<User> adminsList = new List();
  bool isLoading = true;

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
    if (widget.user.subLevel > 0) {
      notifyMembers = true;
    }
    game = new Game(
        "",
        0,
        null,
        "",
        "",
        "",
        "",
        0,
        0,
        "",
        "No Limit Hold'em",
        9,
        0,
        0,
        0,
        0,
        "",
        "",
        true,
        widget.user.currency,
        false,
        0,
        true,
        1,
        widget.user.id,
        widget.user.fcm,
        widget.user.userName,
        0,
        false,
        addonPrice: 0,
        rebuyPrice: 0,
        placesPaid: 0,
        subOrAddPP: 0,
        add: true);
    getAdmins();
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

      if (game.date == "") {
        game.date = day + "/" + month;
      }
      if (game.time == "") {
        game.time = hour + ":" + minute;
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
        OwnCloudFunctions().groupNotification(
            "Tournament!",
            game,
            widget.group,
            "New Tournament!",
            "${widget.group.name} has invited you to join ${game.name}",
            true);
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

  void getAdmins() async {
    QuerySnapshot qSnap = await firestoreInstance
        .collection("groups/${widget.group.id}/members")
        .getDocuments();

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
    setState(() {
      isLoading = false;
    });
  }

  Widget page() {
    return new SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Layout().padded(
            child: new TextFormField(
              initialValue: "${game.getName()}",
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
                  initialValue: game.maxPlayers.toString(),
                  style: new TextStyle(color: UIData.blackOrWhite),
                  key: new Key('maximumplayers'),
                  decoration: new InputDecoration(
                      labelText: 'Maximum players',
                      labelStyle: new TextStyle(color: Colors.grey[600])),
                  autocorrect: false,
                  validator: (val) {
                    int isNumber = int.tryParse(val);
                    if (isNumber != null) {
                      val.isEmpty ? val = game.maxPlayers.toString() : null;
                      // if (widget.user.subLevel < 2) {
                      //   String sub;
                      //   if (widget.user.subLevel == 1 &&
                      //       int.tryParse(val) > 27) {
                      //     sub =
                      //         "Your current subscription only allows \n27 players per tournament";
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => Subscription(
                      //                   user: widget.user,
                      //                   info: true,
                      //                   title: sub,
                      //                 )));
                      //     return sub;
                      //   } else if (widget.user.subLevel == 0 &&
                      //       int.tryParse(val) > 9) {
                      //     sub =
                      //         "Your current subscription only allows \n9 players per tournament";
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => Subscription(
                      //                   user: widget.user,
                      //                   info: true,
                      //                   title: sub,
                      //                 )));
                      //     return sub;
                      //   }
                      // }
                    } else {
                      return "Input must be a number!";
                    }
                  },
                  onSaved: (val) {
                    if (val.isEmpty) {
                      // switch (widget.user.subLevel) {
                      //   case (0):
                      //     game.setMaxPlayers(9);
                      //     break;
                      //   case (1):
                      //     game.setMaxPlayers(18);
                      //     break;
                      //   case (2):
                          game.setMaxPlayers(27);
                      //     break;
                      // }
                    // } else if (widget.user.subLevel == 1 &&
                    //     int.tryParse(val) > 27) {
                    //   game.setMaxPlayers(27);
                    // } else if (widget.user.subLevel == 0 &&
                    //     int.tryParse(val) > 9) {
                    //   game.setMaxPlayers(9);
                    } else {
                      game.setMaxPlayers(int.tryParse(val));
                    }
                  })),
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
                    validator: (val) {
                      int isNumber = int.tryParse(val);
                      if (isNumber != null) {
                      } else {
                        return "Input must be a number!";
                      }
                    },
                    onSaved: (val) {
                      if (val.isEmpty) {
                        game.setBuyin(0);
                      } else {
                        game.setBuyin(int.tryParse(val));
                      }
                      if (sameAsBuyin) {
                        game.rebuyPrice = game.buyin;
                        game.addonPrice = game.buyin;
                      }
                    }),
              )
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
                  validator: (val) {
                    int isNumber = int.tryParse(val);
                    if (isNumber != null) {
                    } else {
                      return "Input must be a number!";
                    }
                  },
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
                    validator: (val) {
                      int isNumber = int.tryParse(val);
                      if (isNumber != null) {
                      } else {
                        return "Input must be a number!";
                      }
                    },
                    onSaved: (val) => val.isEmpty
                        ? game.setAddon(0)
                        : game.setAddon(int.tryParse(val))),
              ),
            ],
          ),
          returnPadding(),
          rebuyPrice(),
          Padding(
            padding: EdgeInsets.only(bottom: 18.0, top: 18.0),
            child: new CheckboxListTile(
                title: new Text(
                  "Same price as buyin?",
                  style: new TextStyle(color: UIData.blackOrWhite),
                ),
                subtitle: new Text(
                  "If the price for rebuy's and addon's is the same as the price for buyin then check this box",
                  style: new TextStyle(color: Colors.grey[600]),
                ),
                value: sameAsBuyin,
                onChanged: (val) {
                  sameAsBuyin = val;
                  showRebuyPrice = !val;
                  setState(() {});
                }),
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
            validator: (val) {
              int isNumber = int.tryParse(val);
              if (val == "" || isNumber != null) {
              } else {
                return "Input must be a number!";
              }
            },
            onSaved: (val) => val.isEmpty
                ? game.setStartingChips("0")
                : game.setStartingChips(val),
          )),
          padded(
              child: new TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  style: new TextStyle(color: UIData.blackOrWhite),
                  key: new Key('currency'),
                  decoration: new InputDecoration(
                      hintText: widget.user.currency,
                      labelText: 'Currency',
                      labelStyle: new TextStyle(color: Colors.grey[600])),
                  autocorrect: false,
                  onSaved: (val) => val.isEmpty
                      ? game.setCurrency(widget.user.currency)
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
                data:
                    Theme.of(context).copyWith(canvasColor: UIData.appBarColor),
                child: new Container(
                    child: new DropdownButton<User>(
                  style: TextStyle(color: UIData.blackOrWhite),
                  hint: new Text(
                    game.floorName,
                    style: new TextStyle(
                        color: UIData.blackOrWhite,
                        fontWeight: FontWeight.bold),
                  ),
                  items: adminsList.map((User user) {
                    return new DropdownMenuItem<User>(
                      value: user,
                      child: new Text(
                        user.userName,
                        style: new TextStyle(color: UIData.blackOrWhite),
                      ),
                    );
                  }).toList(),
                  onChanged: (_) {
                    if (game.floorName != _.userName) {
                      setState(() {
                        game.floorName = _.userName;
                        for (var user in adminsList) {
                          if (user.userName == _.userName) {
                            game.floor = user.id;
                            game.floorFCM = user.fcm;
                            game.floorName = user.userName;
                          }
                        }
                      });
                    }
                  },
                )),
              ),
            ),
          ),
          new CheckboxListTile(
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
                // if (widget.user.subLevel == 0) {
                //   showDisabledNotifications = true;
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => Subscription(
                //                 user: widget.user,
                //                 info: true,
                //                 title:
                //                     "Your current subscription does not include notifications",
                //               )));
                // } else {
                  if (val == true) {
                    notifyMembers = true;
                  } else {
                    notifyMembers = false;
                  }
                // }
                setState(() {});
              }),
          // disabledNotifications(),
          Padding(
            padding: EdgeInsets.only(bottom: 48.0),
          )
        ],
      ),
    );
  }

  bool showRebuyPrice = false;

  Widget returnPadding() {
    if (showRebuyPrice) {
      return Padding(
        padding: EdgeInsets.only(top: 18.0),
      );
    } else {
      return Container();
    }
  }

  Widget rebuyPrice() {
    if (showRebuyPrice) {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: 120.0,
            child: new TextFormField(
              keyboardType: TextInputType.number,
              keyboardAppearance: Brightness.dark,
              style: new TextStyle(color: UIData.blackOrWhite),
              key: new Key('rebuy price'),
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Rebuy price",
                  labelStyle: new TextStyle(color: Colors.grey[600])),
              autocorrect: false,
              validator: (val) {
                int isNumber = int.tryParse(val);
                if (isNumber != null) {
                } else {
                  return "Input must be a number!";
                }
              },
              onSaved: (val) => val.isEmpty
                  ? game.rebuyPrice = game.buyin
                  : game.rebuyPrice = int.tryParse(val),
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
                key: new Key('addon price'),
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Addon price",
                    labelStyle: new TextStyle(color: Colors.grey[600])),
                autocorrect: false,
                validator: (val) {
                  int isNumber = int.tryParse(val);
                  if (isNumber != null) {
                  } else {
                    return "Input must be a number!";
                  }
                },
                onSaved: (val) => val.isEmpty
                    ? game.addonPrice = game.buyin
                    : game.addonPrice = int.tryParse(val)),
          ),
        ],
      );
    } else {
      return new Container();
    }
  }

  // bool showDisabledNotifications = false;
  // Widget disabledNotifications() {
  //   if (showDisabledNotifications) {
  //     return new Padding(
  //         padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 18.0),
  //         child: Text(
  //           "Your current subscription does not include notifications",
  //           style: new TextStyle(color: Colors.red),
  //         ));
  //   } else {
  //     return new Container();
  //   }
  // }

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
