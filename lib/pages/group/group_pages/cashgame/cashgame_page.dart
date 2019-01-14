import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/pages/group/group_pages/cashgame/cashgame_settings_page.dart';
import 'package:yadda/utils/time.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/group/new/new_post_page.dart';
import 'cashgame_player_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/objects/game.dart';

class CashGamePage extends StatefulWidget {
  CashGamePage(
      {Key key,
      this.user,
      this.gameId,
      this.group,
      this.history,
      this.fromNotification})
      : super(key: key);
  final User user;
  final String gameId;
  final Group group;
  final bool history;
  final bool fromNotification;

  @override
  CashGamePageState createState() => CashGamePageState();
}

enum FormType { edit, normal }

class CashGamePageState extends State<CashGamePage>
    with TickerProviderStateMixin {
  static final formKey = new GlobalKey<FormState>();
  final Firestore firestoreInstance = Firestore.instance;
  FormType _formType = FormType.normal;
  bool isLoading = false;
  TabController _tabController;

  String currentUserId;
  String currentUserName;
  String playerName;
  String host;
  String joinLeave = "";

  String logPath;
  String gamePath;

  bool hasJoined;
  bool isAdmin = false;
  bool userFound = false;
  bool full = false;
  // bool isLoading = false;
  bool queueExists;

  int registeredPlayers;
  String positionInQueue;
  int playersInQueue = 0;

  String name;
  String adress;
  int maxPlayers;
  int sBlind;
  int bBlind;
  String dayOfWeek;
  String date;
  String time;
  String gameType;
  String info;

  String registeredOrQueue;
  String groupId;

  IconData playerOrResultsIcon = Icons.people;
  String playerOrResultsString = "Players";
  IconData queueOrCalculateIcon = Icons.timer;
  String queueOrCalculateString = "Waiting";

  String cashGameActiveOrHistory = "cashgameactive";

  Color color;
  Color red = UIData.red;
  Color green = UIData.green;
  Color blue = Colors.blue;

  String activeOrNot = "activeplayers";

  List<String> queueList = new List();

  Game game;

  initState() {
    super.initState();
    currentUserId = widget.user.getId();
    currentUserName = widget.user.getName();
    groupId = widget.group.id;

    isAdmin = widget.group.admin;

    _tabController = new TabController(vsync: this, length: 4);
    if (isAdmin == true) {
      _formType = FormType.edit;
    }
    if (widget.history == true) {
      activeOrNot = "players";
      playerOrResultsIcon = FontAwesomeIcons.trophy;
      playerOrResultsString = "Results";
      cashGameActiveOrHistory = "cashgamehistory";
    }
    gamePath =
        'groups/${widget.group.id}/games/type/$cashGameActiveOrHistory/${widget.gameId}';
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

  Scaffold page() {
    return new Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: UIData.blackOrWhite),
          title: new Align(
              child: new Text(
            game.name,
            style: TextStyle(
              color: UIData.blackOrWhite,
            ),
          )),
          actions: <Widget>[
            newPostButton(),
            settingsButton(),
            Padding(
              padding: EdgeInsets.only(left: 12),
            ),
          ],
          backgroundColor: UIData.appBarColor,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.info,
                  color: UIData.blackOrWhite,
                  size: 30.0,
                ),
                text: "Status",
              ),
              Tab(
                icon: Icon(
                  Icons.message,
                  color: Colors.grey[600],
                  size: 30.0,
                ),
                text: "Posts",
              ),
              Tab(
                icon: Icon(
                  playerOrResultsIcon,
                  color: Colors.blue,
                  size: 30.0,
                ),
                text: playerOrResultsString,
              ),
              Tab(
                icon: Icon(
                  queueOrCalculateIcon,
                  color: UIData.green,
                  size: 30.0,
                ),
                text: queueOrCalculateString,
              ),
            ],
          ),
        ),
        backgroundColor: UIData.dark,
        floatingActionButton: floatingActionButton(),
        body: new Stack(
          children: <Widget>[
            new TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  padding: EdgeInsets.all(10.0),
                  children: <Widget>[
                    new Text(
                      "${game.name}",
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
                      style: TextStyle(color: UIData.blackOrWhite),
                      overflow: TextOverflow.ellipsis,
                    ),
                    new Text(
                      "Max players: ${game.maxPlayers}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Text(
                      "Blinds: ${game.sBlind}/${game.bBlind}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Text(
                      "Starting Date: ${game.date}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Text(
                      "Starting Time: ${game.time}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    new Padding(
                      padding: EdgeInsets.all(15.0),
                    ),
                    new Text(
                      "${game.info}",
                      style: new TextStyle(color: UIData.blackOrWhite),
                    ),
                  ],
                ),
                streamOfPosts(),
                setPlayersOrResult(),
                setQueueOrPayouts(),
              ],
            ),
            secondLoading(),
          ],
        ));
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

  setQueue() {
    setState(() {
      joinLeave = "Queue";
      color = blue;
    });
  }

  Widget floatingActionButton() {
    if (widget.history != true) {
      return new FloatingActionButton(
        backgroundColor: color,
        tooltip: "Join",
        child: Text(joinLeave),
        onPressed: () {
          if (hasJoined == true) {
            removePlayer();
          } else {
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
      DocumentSnapshot dSnap1 = await firestoreInstance
          .document("$gamePath/activeplayers/$currentUserId")
          .get();
      firestoreInstance.runTransaction((Transaction tx) async {
        DocumentSnapshot dSnap2 = await firestoreInstance
            .document("$gamePath/queue/$currentUserId")
            .get();
        if (dSnap1.exists || dSnap2.exists) {
          hasJoined = true;
          setLeave();
        } else if (hasJoined != true &&
            game.registeredPlayers >= game.maxPlayers) {
          full = true;
          setQueue();
        } else {
          full = false;
          setJoin();
        }
      });
    });
  }

  addPlayer() {
    hasJoined = true;
    setLeave();
    if (full != true) {
      firestoreInstance.runTransaction((Transaction tx) async {
        await firestoreInstance
            .document("$gamePath/activeplayers/$currentUserId")
            .setData({
          'name': currentUserName,
          'id': currentUserId,
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
              "buyin": 0,
              "payout": 0,
            });
          });
        }
      });

      Log().postLogToCollection(
          "$currentUserName joined game", logPath, "Joined");
    } else {
      Time time = new Time();

      firestoreInstance.runTransaction((Transaction tx) async {
        await firestoreInstance
            .document("$gamePath/queue/$currentUserId")
            .setData({
          'name': currentUserName,
          'id': currentUserId,
          'orderbytime': time.getOrderByTime(),
        });
        checkIfFull();
      });
      Log().postLogToCollection(
          "$currentUserName joined queue", logPath, "Joined");
    }
  }

  removePlayer() {
    hasJoined = false;
    firestoreInstance.runTransaction((Transaction tx) async {
      await firestoreInstance
          .document("$gamePath/activeplayers/$currentUserId")
          .delete();
      firestoreInstance.runTransaction((Transaction tx) async {
        await firestoreInstance
            .document("$gamePath/queue/$currentUserId")
            .delete();
        checkIfFull();
        if (full == true) {
          setQueue();
        } else {
          setJoin();
        }
      });
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
          null,
          null,
          docSnap.data["id"],
          docSnap.data["info"],
          docSnap.data["name"],
          docSnap.data["fittedname"],
          docSnap.data["adress"],
          docSnap.data["bblind"],
          null,
          docSnap.data["date"],
          docSnap.data["gametype"],
          docSnap.data["maxplayers"],
          docSnap.data["orderbytime"],
          null,
          docSnap.data["registeredplayers"],
          docSnap.data["sblind"],
          null,
          docSnap.data["time"],
          docSnap.data["calculatepayouts"],
          docSnap.data["currency"],
          docSnap.data["isrunning"],
        );

        if (game.calculatePayouts == true && widget.history == true) {
          queueOrCalculateIcon = Icons.attach_money;
          queueOrCalculateString = "Payouts";
        }
        checkIfFull();
        userFound = true;
        setScreen();
      }
    });
  }

  Widget newPostButton() {
    if (isAdmin == true) {
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
                  builder: (context) => NewPostPage(
                      widget.user,
                      widget.group,
                      "groups/$groupId/games/type/$cashGameActiveOrHistory/${widget.gameId}/posts",
                      true,
                      true)));
        },
      );
    } else {
      return new IconButton(
        icon: Icon(
          Icons.settings,
          color: UIData.appBarColor,
        ),
        onPressed: null,
      );
    }
  }

  Widget settingsButton() {
    if (isAdmin == true) {
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
                builder: (context) => CashGameSettingsPage(
                      user: widget.user,
                      group: widget.group,
                      game: game,
                      callBack: () => checkIfFull(),
                      history: widget.history,
                    )),
          );
        },
      );
    } else {
      return new IconButton(
        icon: Icon(
          Icons.settings,
          color: UIData.appBarColor,
        ),
        onPressed: null,
      );
    }
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
      body: Center(
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

  pushPlayerPage(String id, int buyin, int payout, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CashGamePlayerPage(
                user: widget.user,
                playerId: id,
                playerUserName: name,
                buyinAmount: buyin,
                payout: payout,
                group: widget.group,
                game: game,
                history: widget.history,
                callBack: () => checkIfFull(),
              )),
    );
  }

  Widget _registeredList(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      leading: new Icon(
        Icons.person,
        color: UIData.blue,
        size: 40.0,
      ),
      title: new Text(
        document.data["name"],
        style: new TextStyle(fontSize: 25.0, color: UIData.blackOrWhite),
        overflow: TextOverflow.ellipsis,
      ),
      // trailing: iconButtonDelete(document.documentID),
      onTap: () {
        setState(() {
          isLoading = true;
        });
        firestoreInstance
            .document(
                "groups/$groupId/games/type/cashgameactive/${widget.gameId}/players/${document.documentID}")
            .get()
            .then((datasnapshot) {
          int buyin = datasnapshot.data["buyin"];
          int payout = datasnapshot.data["payout"];

          setState(() {
            isLoading = false;
          });
          pushPlayerPage(
              document.documentID, buyin, payout, document.data["name"]);
        });
      },
    );
  }

  Widget registered() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection(
                "groups/$groupId/games/type/cashgameactive/${widget.gameId}/activeplayers")
            // .orderBy("orderbytime")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _registeredList(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget calculatePayoutsList(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      dense: true,
      title: new Row(
        // crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(
            "${document.data["personnegative"]} ",
            style: new TextStyle(color: UIData.red, fontSize: 20.0),
            overflow: TextOverflow.ellipsis,
          ),

          // new Icon(Icons.arrow_forward, color: UIData.blackOrWhite,),
          new Text(
            "${document.data["personpositive"]} ",
            style: new TextStyle(color: UIData.green, fontSize: 20.0),
            overflow: TextOverflow.ellipsis,
            // textAlign: TextAlign.center,
          ),
        ],
      ),
      contentPadding: EdgeInsets.all(10.0),
      subtitle: new Text(
        "${document.data["sentence"]}",
        // overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,

        style: new TextStyle(
            color: UIData.blackOrWhite,
            fontSize: UIData.fontSize16,
            letterSpacing: .50),
      ),
    );
  }

  Widget calculatePayouts() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection(
                "groups/$groupId/games/type/cashgamehistory/${widget.gameId}/payouts")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                calculatePayoutsList(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget queue() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection(
                "groups/$groupId/games/type/cashgameactive/${widget.gameId}/queue")
            .orderBy("orderbytime")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _queueList(context, snapshot.data.documents[index]),
          );
        });
  }

  addPlayerFromQueue(String name, String uid) {
    Time time = new Time();
    firestoreInstance
        .document(
            "groups/$groupId/games/type/cashgameactive/${widget.gameId}/players/$uid")
        .get()
        .then((datasnapshot) {
      if (datasnapshot.exists) {
      } else {
        firestoreInstance
            .document(
                "groups/$groupId/games/type/cashgameactive/${widget.gameId}/players/$uid")
            .setData({
          'name': name,
          'id': uid,
          'orderbytime': time.getOrderByTime(),
          'buyin': 0,
          'payout': "0",
        });
      }
    });
    firestoreInstance
        .document(
            "groups/$groupId/games/type/cashgameactive/${widget.gameId}/activeplayers/$uid")
        .setData({
      'name': name,
      'id': uid,
      'orderbytime': time.getOrderByTime(),
    });
    Log().postLogToCollection(
        "$currentUserName moved $name from queue to game",
        "groups/$groupId/games/type/cashgameactive/${widget.gameId}/log",
        "Move");

    firestoreInstance
        .document(
            "groups/$groupId/games/type/cashgameactive/${widget.gameId}/queue/$uid")
        .delete();
  }

  Widget _queueList(BuildContext context, DocumentSnapshot document) {
    return ListTile(
        leading: new Icon(
          Icons.person,
          color: UIData.blue,
          size: 40.0,
        ),
        title: new Text(
          document.data["name"],
          style: new TextStyle(fontSize: 25.0),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: tapToAdd(),
        onTap: () {
          if (isAdmin == true) {
            addPlayerFromQueue(document.data["name"], document.data["id"]);
          }
        });
  }

  Widget tapToAdd() {
    if (isAdmin == true) {
      return new Text(
        "Tap to add player to game",
        style: new TextStyle(fontSize: UIData.fontSize16),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return new Text("");
    }
  }

  setPlayersOrResult() {
    if (widget.history == true) {
      return resultStream();
    } else {
      return registered();
    }
  }

  setQueueOrPayouts() {
    if (widget.history == true) {
      return calculatePayouts();
    } else {
      return queue();
    }
  }

  Widget _resultList(BuildContext context, DocumentSnapshot document) {
    String result;
    Color color;

    int payout = document.data["payout"];
    int buyin = document.data["buyin"];
    print(payout - buyin);
    if (payout != null && buyin != null) {
      int r = payout - buyin;
      if (!r.isNegative) {
        color = UIData.green;
        result = r.toString();
        result = "+$result";
      } else {
        result = r.toString();
        color = UIData.red;
      }
    } else {
      result = document.data["payout"];
    }
    return ListTile(
      title: new Text(
        "${document.data["name"]} ",
        style: new TextStyle(fontSize: 24.0, color: UIData.blackOrWhite),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: new Text(
        "$result",
        style: new TextStyle(fontSize: 18.0, color: color),
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
          int playerBuyin = datasnapshot.data["buyin"];
          int payout = datasnapshot.data["payout"];

          setState(() {
            isLoading = false;
          });
          pushPlayerPage(
              document.documentID, playerBuyin, payout, document.data["name"]);
        });
      },
    );
  }

  Widget resultStream() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection("$gamePath/players")
            .orderBy("payout")
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
                    .document(
                        "groups/$groupId/games/type/$cashGameActiveOrHistory/${widget.gameId}/posts/${document.documentID}")
                    .delete();
                Log().postLogToCollection(
                    "$currentUserName deleted a post",
                    "groups/$groupId/games/type/$cashGameActiveOrHistory/${widget.gameId}/log",
                    "Post");
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
            .collection(
                "groups/$groupId/games/type/$cashGameActiveOrHistory/${widget.gameId}/posts")
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
