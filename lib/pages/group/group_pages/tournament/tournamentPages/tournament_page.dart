import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/pages/group/group_pages/tournament/tournamentPages/tournament_settings_page.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/group/new/new_post_page.dart';
import 'tournament_player_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/objects/game.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TournamentPage extends StatefulWidget {
  TournamentPage({
    Key key,
    this.user,
    this.gameId,
    this.history,
    this.group,
    this.fromNotification,
  }) : super(key: key);
  final User user;
  final Group group;
  final String gameId;
  final bool history;
  final bool fromNotification;

  @override
  TournamentPageState createState() => TournamentPageState();
}

enum FormType { edit, normal }

class TournamentPageState extends State<TournamentPage>
    with TickerProviderStateMixin {
  final Firestore firestoreInstance = Firestore.instance;
  FormType _formType = FormType.normal;
  TabController _tabController;

  String currentUserId;
  String currentUserName;

  String groupId;
  String logPath;
  String gamePath;

  String playerName;
  String host;
  String joinLeave = "";

  bool admin = false;
  bool userFound = false;
  bool full = false;
  bool isLoading = false;
  bool hasJoined;

  IconData playerOrResultsIcon = Icons.people;
  double playerOrResultsIconSize = 30;
  String playerOrResultsString = "Players";
  String tournamentActiveOrHistory = "tournamentactive";

  Color color;
  Color red = UIData.red;
  Color green = UIData.green;
  Color blue = UIData.blue;

  Game game;

  String activeOrNot = "activeplayers";

  @override
  initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 4);

    currentUserId = widget.user.id;
    currentUserName = widget.user.userName;
    groupId = widget.group.id;

    admin = widget.group.admin;

    if (admin == true) {
      _formType = FormType.edit;
    }
    if (widget.history == true) {
      activeOrNot = "players";
      playerOrResultsIcon = FontAwesomeIcons.trophy;
      playerOrResultsIconSize = 25;
      playerOrResultsString = "Results";
      tournamentActiveOrHistory = "tournamenthistory";
    }
    gamePath =
        'groups/${widget.group.id}/games/type/$tournamentActiveOrHistory/${widget.gameId}';
    logPath = "$gamePath/log";
    getGroup();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return setScreen();
  }

  setJoin() {
    setState(() {
      joinLeave = "Join";
      color = green;
    });
  }

  setLeave() {
    setState(() {
      joinLeave = "Leave";
      color = red;
    });
  }

  setFull() {
    setState(() {
      joinLeave = "Full";
      color = blue;
    });
  }

  FloatingActionButton floatingActionButton() {
    if (widget.history != true) {
      return new FloatingActionButton(
        backgroundColor: color,
        tooltip: "Join",
        child: Text(joinLeave),
        onPressed: () {
          if (hasJoined == true) {
            removePlayer();
          } else if (hasJoined == false &&
              game.registeredPlayers < game.maxPlayers) {
            addPlayer();
          }
        },
      );
    }
    return null;
  }

  checkIfFull() {
    if (game != null) {
      try {
        firestoreInstance.runTransaction((Transaction tx) async {
          QuerySnapshot qSnap = await firestoreInstance
              .collection("$gamePath/$activeOrNot")
              .getDocuments();
          if (qSnap.documents.isNotEmpty) {
            game.setRegisteredPlayers(qSnap.documents.length);
          } else {
            game.setRegisteredPlayers(0);
          }
          game.setGameRegisteredPlayers(gamePath);
          checkPlayerGameStatus();
        });
      } catch (e) {}
    }
  }

  checkPlayerGameStatus() {
    firestoreInstance.runTransaction((Transaction tx) async {
      DocumentSnapshot dSnap = await firestoreInstance
          .document("$gamePath/activeplayers/$currentUserId")
          .get();
      if (dSnap.exists) {
        hasJoined = true;
        setLeave();
      } else if (hasJoined != true &&
          game.registeredPlayers >= game.maxPlayers) {
        full = true;
        setFull();
      } else {
        hasJoined = false;
        setJoin();
      }
    });
  }

  addPlayer() {
    hasJoined = true;
    setLeave();
    firestoreInstance.runTransaction((Transaction tx) async {
      await firestoreInstance
          .document("$gamePath/activeplayers/$currentUserId")
          .setData({
        'name': currentUserName,
        'id': currentUserId,
        "placing": game.maxPlayers,
      });
      checkIfFull();
    });
    firestoreInstance.runTransaction((Transaction tx) async {
      DocumentSnapshot docSnap = await firestoreInstance
          .document("$gamePath/players/$currentUserId")
          .get();
      if (!docSnap.exists) {
        firestoreInstance.runTransaction((Transaction tx) async {
          await firestoreInstance
              .document("$gamePath/players/$currentUserId")
              .setData({
            'name': currentUserName,
            'id': currentUserId,
            "placing": game.maxPlayers,
            'payout': "0",
            'rebuy': 0,
            'addon': 0,
          });
        });
      }
    });

    Log()
        .postLogToCollection("$currentUserName joined game", logPath, "Joined");
  }

  removePlayer() {
    hasJoined = false;
    setJoin();
    firestoreInstance.runTransaction((Transaction tx) async {
      await firestoreInstance
          .document("$gamePath/activeplayers/$currentUserId")
          .delete();
      checkIfFull();
    });
    Log().postLogToCollection("$currentUserName left game", logPath, "Leave");
  }

// Check if player has registered the tournament, add and delete player to/from tournament.

  getGroup() {
    firestoreInstance.runTransaction((Transaction tx) async {
      DocumentSnapshot docSnap =
          await firestoreInstance.document("$gamePath").get();
      if (docSnap.data.isNotEmpty) {
        game = new Game(
          docSnap.data["totalprizepool"],
          docSnap.data["addon"],
          docSnap.data["id"],
          docSnap.data["info"],
          docSnap.data["name"],
          docSnap.data["fittedname"],
          docSnap.data["adress"],
          null,
          docSnap.data["buyin"],
          docSnap.data["date"],
          docSnap.data["gametype"],
          docSnap.data["maxplayers"],
          docSnap.data["orderbytime"],
          docSnap.data["rebuy"],
          docSnap.data["registeredplayers"],
          null,
          docSnap.data["startingchips"],
          docSnap.data["time"],
          docSnap.data["calculatepayouts"],
          docSnap.data["currency"],

        );
        checkIfFull();
        userFound = true;
        setScreen();
      }
    });
  }

  Widget newPostButton() {
    if (admin == true) {
      return new IconButton(
        icon: new Icon(
          Icons.message,
          color: Colors.grey[600],
          size: 30.0,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewPostPage(widget.user, widget.group,
                      "$gamePath/posts", true, true)));
        },
      );
    } else {
      return new IconButton(
        icon: Icon(Icons.person, color: UIData.appBarColor, size: 0,)
        ,
      );
    }
  }

  Widget settingsButton() {
    if (admin == true) {
      return new IconButton(
        icon: new Icon(
          Icons.settings,
          color: Colors.grey[600],
          size: 30.0,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TournamentSettingsPage(
                      user: widget.user,
                      game: game,
                      group: widget.group,
                      history: widget.history,
                      callBack: () => checkIfFull(),
                    )),
          );
        },
      );
    } else {
       return new IconButton(
        icon: Icon(Icons.person, color: UIData.appBarColor, size: 0,)
        ,
      );
    }
  }

  Scaffold page() {
    return Scaffold(
        floatingActionButton: floatingActionButton(),
        backgroundColor: UIData.dark,
        appBar: AppBar(
          // centerTitle: true,
            iconTheme: IconThemeData(color: UIData.blackOrWhite),
            actions: <Widget>[
              newPostButton(),
              settingsButton(),
              Padding(padding: EdgeInsets.only(left: 10),),
            ],
            backgroundColor: UIData.appBarColor,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.info,
                    color: UIData.blackOrWhite,
                    size: 30,
                  ),
                  text: "Info",
                ),
                Tab(
                  icon: Icon(
                    Icons.message,
                    color: Colors.grey[600],
                    size: 30,
                  ),
                  text: "Posts",
                ),
                Tab(
                  icon: Icon(
                    playerOrResultsIcon,
                    color: Colors.blue,
                    size: playerOrResultsIconSize,
                  ),
                  text: playerOrResultsString,
                ),
                Tab(
                  icon: Icon(
                    Icons.attach_money,
                    size: 30,
                    color: UIData.green,
                  ),
                  text: "Payouts",
                ),
              ],
            ),
            title: new Align(
                alignment: Alignment.center,
                child: new Text(
                  game.name,
                  style: new TextStyle(
                      color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
                ))),
        body: Stack(
          children: <Widget>[
            TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  padding: EdgeInsets.all(10.0),
                  children: <Widget>[
                    new Text(
                      game.name,
                      style: TextStyle(color: UIData.blackOrWhite),
                      overflow: TextOverflow.ellipsis,
                    ),
                    new Padding(
                      padding: EdgeInsets.all(15.0),
                    ),
                    new Text(
                      "Gametype: ${game.gameType}",
                      style: TextStyle(color: UIData.blackOrWhite),
                      overflow: TextOverflow.ellipsis,
                    ),
                    new Text(
                      "Adress: ${game.adress}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Text(
                      "Buy-in: ${game.buyin}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Text(
                      "Rebuy: ${game.rebuy}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Text(
                      "Addon: ${game.addon}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Text(
                      "Starting stack: ${game.startingChips}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Text(
                      "Starting date: ${game.date}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Text(
                      "Starting time: ${game.time}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Padding(
                      padding: EdgeInsets.all(15.0),
                    ),
                    new Text(
                      game.info,
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(color: UIData.blackOrWhite),
                    ),
                  ],
                ),
                streamOfPosts(),
                setPlayersOrResult(),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: new Text(
                    "Prize Pool:\n\n${game.totalPrizePool}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: UIData.blackOrWhite),
                  ),
                ),
              ],
            ),
            secondLoading(),
          ],
        ));
  }

  Widget secondLoading() {
    if (isLoading == true) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new Text("");
    }
  }

  Scaffold loading() {
    return new Scaffold(
      backgroundColor: UIData.dark,
      body: new Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }

  setScreen() {
    if (userFound == false) {
      return loading();
    } else {
      return page();
    }
  }

  setPlayersOrResult() {
    if (widget.history == true) {
      return resultStream();
    } else {
      return playerList();
    }
  }

  pushPlayerPage(String id, int placing, int addon, int rebuy, String payout,
      String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TournamentPlayerPage(
                user: widget.user,
                playerId: id,
                playerUserName: name,
                group: widget.group,
                oldPayout: payout,
                oldPlacing: placing,
                oldAddon: addon,
                oldRebuy: rebuy,
                gameId: widget.gameId,
                callback: () => getGroup(),
              )),
    );
  }

  Widget _playerListItems(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      leading: new Icon(
        Icons.person,
        color: Colors.blue,
        size: 40.0,
      ),
      title: new Text(
        document.data["name"],
        style: new TextStyle(fontSize: 25.0),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        setState(() {
          isLoading = true;
        });
        firestoreInstance
            .document("$gamePath/players/${document.documentID}")
            .get()
            .then((datasnapshot) {
          int playerAddon = datasnapshot.data["addon"];
          int playerRebuy = datasnapshot.data["rebuy"];
          int playerPlacing = datasnapshot.data["placing"];
          String playerPayout = datasnapshot.data["payout"];
          setState(() {
            isLoading = false;
          });
          pushPlayerPage(document.documentID, playerPlacing, playerAddon,
              playerRebuy, playerPayout, document.data["name"]);
        });
      },
    );
  }

  Widget playerList() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection("$gamePath/activeplayers")
            .orderBy("name")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _playerListItems(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget _resultList(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      leading: new Text(
        "${document.data["placing"]}.",
        style: new TextStyle(fontSize: 24.0, color: UIData.blackOrWhite),
        overflow: TextOverflow.ellipsis,
      ),
      title: new Text(
        "${document.data["name"]} ",
        style: new TextStyle(fontSize: 24.0, color: UIData.blackOrWhite),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: new Text(
        "Payout: ${document.data["payout"]}",
        style: new TextStyle(fontSize: 18.0, color: UIData.blackOrWhite),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        setState(() {
          isLoading = true;
        });
        firestoreInstance
            .document("$gamePath/players/${document.documentID}")
            .get()
            .then((datasnapshot) {
          int playerAddon = datasnapshot.data["addon"];
          int playerRebuy = datasnapshot.data["rebuy"];
          int playerPlacing = datasnapshot.data["placing"];
          String playerPayout = datasnapshot.data["payout"];
          setState(() {
            isLoading = false;
          });
          pushPlayerPage(document.documentID, playerPlacing, playerAddon,
              playerRebuy, playerPayout, document.data["name"]);
        });
      },
    );
  }

  Widget resultStream() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection("$gamePath/players")
            .orderBy("placing")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _resultList(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget _buildStreamOfPosts(BuildContext context, DocumentSnapshot document) {
    switch (_formType) {
      case FormType.normal:
        return new ListTile(
          dense: true,
          title: new Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                "${document.data["name"]} ",
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
            "${document.data["body"]}",
            // overflow: TextOverflow.ellipsis,
            style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
                letterSpacing: .50),
          ),
        );
      case FormType.edit:
        return new ListTile(
          trailing: new IconButton(
              icon: new Icon(
                Icons.delete,
                size: 40.0,
                color: UIData.red,
              ),
              onPressed: () {
                Firestore.instance
                    .document("$gamePath/posts/${document.documentID}")
                    .delete();
                Log().postLogToCollection(
                    "$currentUserName deleted a post", logPath, "Post");
              }),
          dense: true,
          title: new Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                "${document.data["name"]}",
                style: new TextStyle(color: UIData.blue, fontSize: 20.0),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          contentPadding: EdgeInsets.all(10.0),
          subtitle: new Text(
            "${document.data["body"]}",
            // overflow: TextOverflow.ellipsis,
            style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize16,
                letterSpacing: .50),
          ),
        );
    }
  }

  Widget streamOfPosts() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("$gamePath/posts")
            .orderBy("orderbytime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return loading();
          else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  _buildStreamOfPosts(context, snapshot.data.documents[index]),
            );
          }
        });
  }
}
