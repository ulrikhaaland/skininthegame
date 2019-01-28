import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/objects/game.dart';
import 'package:yadda/utils/log.dart';

class TournamentCreatePlayerPage extends StatefulWidget {
  TournamentCreatePlayerPage(
      {Key key,
      this.user,
      this.history,
      this.group,
      this.gameId,
      this.game,
      this.callBack,
      this.fromCash})
      : super(key: key);
  final User user;
  final Group group;
  final Game game;
  final String gameId;
  final bool history;
  final bool fromCash;
  final VoidCallback callBack;

  @override
  TournamentCreatePlayerPageState createState() =>
      TournamentCreatePlayerPageState();
}

class TournamentCreatePlayerPageState
    extends State<TournamentCreatePlayerPage> {
  static final formKey = new GlobalKey<FormState>();
  Firestore firestoreInstance = Firestore.instance;

  String groupName;
  String groupId;
  String currentUserId;
  String currentUserName;
  bool userFound = false;
  bool isLoading = false;
  bool admin;
  String playerName;
  String logPath;
  String tournamentOrCashGame;
  String activeOrHistory;

  // @override
  void initState() {
    super.initState();
    currentUserId = widget.user.id;
    currentUserName = widget.user.userName;
    groupName = widget.group.name;
    groupId = widget.group.id;
    if (widget.fromCash != true) {
      tournamentOrCashGame = "tournament";
    } else {
      tournamentOrCashGame = "cashgame";
    }
    activeOrHistory = "${tournamentOrCashGame}active";
    if (widget.history == true) {
      activeOrHistory = "${tournamentOrCashGame}history";
    }
    logPath =
        "groups/$groupId/games/type/$activeOrHistory/${widget.game.id}/log";
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    setState(() {
      isLoading = false;
    });

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: UIData.blackOrWhite),
            backgroundColor: UIData.appBarColor,
            actions: <Widget>[
              new FlatButton(
                  child: new Text(
                    "Create",
                    style: new TextStyle(
                        fontSize: UIData.fontSize16,
                        color: UIData.blackOrWhite),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => addPlayer()),
            ],
            title: new Text(
              "Create Player",
              style: new TextStyle(
                  fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
            )),
        backgroundColor: UIData.dark,
        body: new Stack(
          children: <Widget>[
            new Form(
              key: formKey,
              child: page(),
            ),
            circular(),
          ],
        ));
  }

  Widget circular() {
    if (isLoading == true) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new Text("");
    }
  }

  addPlayer() async {
    QuerySnapshot qSnap = await firestoreInstance
        .collection(
            "groups/$groupId/games/type/$activeOrHistory/${widget.game.id}/activeplayers")
        .getDocuments();
    if (validateAndSave() && qSnap.documents.length < widget.game.maxPlayers) {
      Log().postLogToCollection(
          "$playerName was added to the game", logPath, "Added");
      if (widget.fromCash != true) {
        firestoreInstance.runTransaction((Transaction tx) async {
          await firestoreInstance
              .document(
                  "groups/$groupId/games/type/$activeOrHistory/${widget.game.id}/players/$playerName")
              .setData({
            "name": playerName,
            "placing": widget.game.maxPlayers,
            "payout": 0,
            "rebuy": 0,
            "addon": 0,
          });
        });
        if (widget.history != true) {
          firestoreInstance.runTransaction((Transaction tx) async {
            await firestoreInstance
                .document(
                    "groups/$groupId/games/type/$activeOrHistory/${widget.game.id}/activeplayers/$playerName")
                .setData({
              "name": playerName,
              "placing": widget.game.maxPlayers,
            });
          });
        }
      } else {
        firestoreInstance.runTransaction((Transaction tx) async {
          await firestoreInstance
              .document(
                  "groups/$groupId/games/type/$activeOrHistory/${widget.game.id}/players/$playerName")
              .setData({
            "name": playerName,
            "payout": 0,
            'buyin': 0,
          });
        });
        if (widget.history != true) {
          firestoreInstance.runTransaction((Transaction tx) async {
            await firestoreInstance
                .document(
                    "groups/$groupId/games/type/$activeOrHistory/${widget.game.id}/activeplayers/$playerName")
                .setData({
              "name": playerName,
              'buyin': 0,
              'payout': 0,
            });
          });
        }
      }
      widget.callBack();
      setState(() {
        isLoading = false;
      });
      Scaffold.of(formKey.currentState.context).showSnackBar(new SnackBar(
        backgroundColor: UIData.yellow,
        content: new Text(
          "$playerName has been added to the game",
          textAlign: TextAlign.center,
          style: new TextStyle(color: Colors.black),
        ),
      ));
    } else {
       Scaffold.of(formKey.currentState.context).showSnackBar(new SnackBar(
        backgroundColor: UIData.yellow,
        content: new Text(
          "The game is full, increase the limit to add more players",
          textAlign: TextAlign.center,
          style: new TextStyle(color: Colors.black),
        ),
      ));
    }
  }

  Widget page() {
    return new ListView(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.all(18.0),
          child: new TextFormField(
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: new TextStyle(color: UIData.blackOrWhite),
            key: new Key('playername'),
            decoration: new InputDecoration(
                labelText: 'Name',
                labelStyle: new TextStyle(color: Colors.grey[600])),
            autocorrect: false,
            validator: (val) => val.isEmpty ? "Name can't be empty" : null,
            onSaved: (val) => playerName = val,
          ),
        ),
        new Text(
          "Add a player which does not yet have an account. \n The player will only exist in this game and is entirely under your control",
          style: new TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
