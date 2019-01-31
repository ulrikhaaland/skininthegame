import 'package:flutter/material.dart';
import 'dart:async';
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yadda/pages/profile/profile_page.dart';

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
  String playerOrResultsString = "Active";
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

    if (isAdmin == true) {
      _tabController = new TabController(vsync: this, length: 5);

      _formType = FormType.edit;
    } else {
      _tabController = new TabController(vsync: this, length: 4);
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

  List<Widget> tabs() {
    if (isAdmin && widget.history == false) {
      return [
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
          text: "Wait",
        ),
        Tab(
          icon: Icon(
            Icons.group,
            color: UIData.yellowOrWhite,
            size: 30.0,
          ),
          text: "Totals",
        ),
      ];
    } else {
      return [
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
      ];
    }
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
            tabs: tabs(),
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
                    new Text(
                      "Currency: ${game.currency}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: UIData.blackOrWhite),
                    ),
                    moneyInPlay(),
                    new Padding(
                      padding: EdgeInsets.all(12.0),
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
                all(),
              ],
            ),
            secondLoading(),
          ],
        ));
  }

  moneyInPlay() {
    if (game.showMoneyOnTable) {
      return new Text(
        "Money in play: ${game.moneyOnTable}${game.currency}",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: UIData.blackOrWhite),
      );
    } else {
      return new Container();
    }
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
            removePlayer(widget.user.id, false, widget.user.userName);
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

  addPlayer() async {
    hasJoined = true;
    setLeave();
    if (full != true) {
      firestoreInstance.runTransaction((Transaction tx) async {
        await firestoreInstance
            .document("$gamePath/activeplayers/$currentUserId")
            .setData({
          'name': currentUserName,
          'id': currentUserId,
          "buyin": 0,
          "payout": 0,
          "profilepicurl": widget.user.profilePicURL,
        });
        checkIfFull();
      });

      DocumentReference docRef =
          firestoreInstance.document("$gamePath/players/$currentUserId");
      DocumentSnapshot docSnap = await docRef.get();
      if (!docSnap.exists) {
        await docRef.setData({
          'name': currentUserName,
          'id': currentUserId,
          "buyin": 0,
          "payout": 0,
          "profilepicurl": widget.user.profilePicURL,
        });
        // } else {
        //  DocumentSnapshot docSnap = await tx.get(firestoreInstance.document(gamePath));
        //  await tx.update(firestoreInstance.document(gamePath), {
        //    "moneyontable": docSnap.data["buyin"]
        //  });
        // }
      }

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
          "profilepicurl": widget.user.profilePicURL,
        });
        checkIfFull();
      });
      Log().postLogToCollection(
          "$currentUserName joined queue", logPath, "Joined");
    }
  }

  void updateMoneyOnTable() async {
    if (game.isRunning) {
      int a = 0;
      QuerySnapshot qSnap = await firestoreInstance
          .collection("$gamePath/players")
          .getDocuments();
      qSnap.documents.forEach((doc) {
        int b = doc.data["buyin"];
        int p = doc.data["payout"];
        a += b - p;
      });
      game.moneyOnTable = a;
      firestoreInstance.document(gamePath).updateData({"moneyontable": a});
    }
    return;
  }

  void removePlayer(String uid, bool removed, String name) async {
    updateMoneyOnTable();
    hasJoined = false;
    await firestoreInstance.document("$gamePath/activeplayers/$uid").delete();
    await firestoreInstance.document("$gamePath/queue/$uid").delete();
    checkIfFull();
    if (full == true) {
      setQueue();
    } else {
      setJoin();
    }

    if (removed) {
      Log().postLogToCollection(
          "$currentUserName removed $name from the game", logPath, "Remove");
    } else {
      Log().postLogToCollection("$name left game", logPath, "Leave");
    }
  }

// Check if player has registered the tournament, add and delete player to/from tournament.

  getGroup() {
    firestoreInstance.runTransaction((Transaction tx) async {
      DocumentSnapshot docSnap =
          await firestoreInstance.document("$gamePath").get();
      if (docSnap.data.isNotEmpty) {
        game = new Game(
          "0",
          0,
          docSnap.data["id"],
          docSnap.data["info"],
          docSnap.data["name"],
          docSnap.data["fittedname"],
          docSnap.data["adress"],
          docSnap.data["bblind"],
          0,
          docSnap.data["date"],
          docSnap.data["gametype"],
          docSnap.data["maxplayers"],
          docSnap.data["orderbytime"],
          0,
          docSnap.data["registeredplayers"],
          docSnap.data["sblind"],
          "0",
          docSnap.data["time"],
          docSnap.data["calculatepayouts"],
          docSnap.data["currency"],
          docSnap.data["isrunning"],
          docSnap.data["moneyontable"],
          docSnap.data["showmoneyontable"],
          0
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
                      updateState: () => updateState(),
                      callBack: () => checkIfFull(),
                      history: widget.history,
                      moneyInPlay: () => updateMoneyOnTable(),
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

  pushPlayerPage(
      String id, int buyin, int payout, String name, String url, bool fromAll) {
    bool createdPlayer = false;
    if (id == name) {
      createdPlayer = true;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CashGamePlayerPage(
                url: url,
                user: widget.user,
                playerId: id,
                playerUserName: name,
                buyinAmount: buyin,
                payout: payout,
                group: widget.group,
                game: game,
                history: widget.history,
                callBack: () => checkIfFull(),
                createdPlayer: createdPlayer,
                fromAll: fromAll,
                onUpdate: () => updateMoneyOnTable(),
              )),
    );
  }

  Widget addImage(String url) {
    if (url != null) {
      return new CircleAvatar(
        radius: 25,
        backgroundImage: CachedNetworkImageProvider(url),
        backgroundColor: Colors.grey[600],
      );
    } else {
      return new CircleAvatar(
        radius: 25,
        child: Icon(
          Icons.person_outline,
          color: Colors.white,
          size: 35,
        ),
        backgroundColor: Colors.grey[600],
      );
    }
  }

  Widget _registeredList(BuildContext context, DocumentSnapshot document) {
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
          leading: addImage(document.data["profilepicurl"]),
          title: new Text(
            document.data["name"],
            style: new TextStyle(fontSize: 25.0, color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
          ),
          // trailing: iconButtonDelete(document.documentID),
          onTap: () => pushPlayerPage(
              document.documentID,
              document.data["buyin"],
              document.data["payout"],
              document.data["name"],
              document.data["profilepicurl"],
              false),
          // });
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Remove',
            color: UIData.red,
            icon: Icons.delete,
            onTap: () {
              if (widget.history == true) {
                firestoreInstance.runTransaction((Transaction tx) async {
                  await firestoreInstance
                      .document("$gamePath/players/${document.documentID}")
                      .delete();
                });
              }
              removePlayer(document.documentID, true, document.data["name"]);
            }),
      ],
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
            itemExtent: 60.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _registeredList(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget allList(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      leading: addImage(document.data["profilepicurl"]),
      title: new Text(
        document.data["name"],
        style: new TextStyle(fontSize: 25.0, color: UIData.blackOrWhite),
        overflow: TextOverflow.ellipsis,
      ),
      // trailing: iconButtonDelete(document.documentID),
      onTap: () => pushPlayerPage(
          document.documentID,
          document.data["buyin"],
          document.data["payout"],
          document.data["name"],
          document.data["profilepicurl"],
          true),
    );
  }

  Widget all() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection(
                "groups/$groupId/games/type/cashgameactive/${widget.gameId}/players")
            // .orderBy("orderbytime")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 60.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                allList(context, snapshot.data.documents[index]),
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
            itemExtent: 60.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _queueList(context, snapshot.data.documents[index]),
          );
        });
  }

  addPlayerFromQueue(String name, String uid, String url) {
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
          'payout': 0,
          "profilepicurl": url,
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
      "profilepicurl": url,
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
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
            leading: addImage(document.data["profilepicurl"]),
            title: new Text(
              document.data["name"],
              style: new TextStyle(fontSize: 25.0),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: tapToAdd(),
            onTap: () {
              if (isAdmin == true) {
                addPlayerFromQueue(document.data["name"], document.data["id"],
                    document.data["profilepicurl"]);
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              user: widget.user,
                              profileId: document.documentID,
                            )));
              }
            }),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Remove',
            color: UIData.red,
            icon: Icons.delete,
            onTap: () {
              firestoreInstance
                  .document("$gamePath/queue/${document.documentID}")
                  .delete();
              checkIfFull();
              Log().postLogToCollection(
                  "$currentUserName removed ${widget.user.userName} from the queue",
                  "$gamePath/log",
                  "Remove");
            }),
      ],
    );
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
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
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
              pushPlayerPage(document.documentID, playerBuyin, payout,
                  document.data["name"], document.data["profilepicurl"], false);
            });
          },
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Remove',
            color: UIData.red,
            icon: Icons.delete,
            onTap: () {
              firestoreInstance
                  .document("$gamePath/players/${document.documentID}")
                  .delete();
              Log().postLogToCollection(
                  "$currentUserName removed ${widget.user.userName} from the results",
                  "$gamePath/log",
                  "Remove");
            }),
      ],
    );
  }

  void updateState() {
    setState(() {});
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
