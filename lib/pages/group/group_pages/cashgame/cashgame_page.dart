import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:yadda/service/service_provider.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/pages/group/group_pages/cashgame/cashgame_settings_page.dart';
import 'package:yadda/utils/time.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/group/new/new_post_page.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'cashgame_player_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/objects/game.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yadda/pages/profile/profile_page.dart';
import 'package:yadda/utils/essentials.dart';
import 'dart:math';
import 'package:yadda/widgets/report_dialog.dart';

class CashGamePage extends StatefulWidget {
  CashGamePage({
    Key key,
    this.user,
    this.gameId,
    this.group,
    this.history,
    this.fromNotification,
    this.request,
  }) : super(key: key);
  final User user;
  final String gameId;
  final Group group;
  final bool history;
  final bool fromNotification;
  final bool request;

  @override
  CashGamePageState createState() => CashGamePageState();
}

class CashGamePageState extends State<CashGamePage>
    with TickerProviderStateMixin {
  static final formKey = new GlobalKey<FormState>();
  final Firestore firestoreInstance = Firestore.instance;
  bool isLoading = false;
  TabController _tabController;
  Random random = new Random();

  String currentUserId;
  String currentUserName;
  String playerName;
  String host;
  String joinLeave = "";
  List<PayoutRequest> payoutRequests = <PayoutRequest>[];

  String logPath;
  String gamePath;

  bool hasJoined = false;
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

  bool isScrollable = false;

  initState() {
    super.initState();
    currentUserId = widget.user.getId();
    currentUserName = widget.user.getName();
    groupId = widget.group.id;

    isAdmin = widget.group.admin;

    if (isAdmin == true && widget.history != true) {
      _tabController = new TabController(vsync: this, length: 6);
      isScrollable = true;
      if (widget.request == true) _tabController.index = 5;
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
    calculatePayouts();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return setScreen();
  }

  List<Widget> tabs() {
    if (isAdmin && !widget.history) {
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
        Tab(
          icon: new Stack(children: <Widget>[
            Icon(
              Icons.notification_important,
              color: UIData.blackOrWhite,
              size: 30.0,
            ),
            new Positioned(
              top: 0.0,
              right: 0.0,
              child: notificationAmount(),
            )
          ]),
          text: "Requests",
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

  Widget notificationAmount() {
    if (game.requestAmount > 0) {
      return new CircleAvatar(
        backgroundColor: UIData.red,
        maxRadius: 10,
        child: Text(
          "${game.requestAmount}",
        ),
      );
    } else {
      return new Container();
    }
  }

  Scaffold page() {
    return new Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: UIData.blackOrWhite),
          title: new Text(
            game.name,
            style: TextStyle(
              color: UIData.blackOrWhite,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            newPostButton(),
            settingsButton(),
            Padding(
              padding: EdgeInsets.only(left: 12),
            ),
          ],
          backgroundColor: UIData.appBarColor,
          bottom: TabBar(
            labelColor: UIData.blackOrWhite,
            isScrollable: isScrollable,
            controller: _tabController,
            tabs: tabs(),
          ),
        ),
        backgroundColor: UIData.dark,
        floatingActionButton: floatingActionButton(),
        body: new Form(
            key: formKey,
            child: Stack(
              children: <Widget>[
                new TabBarView(
                  controller: _tabController,
                  children: setAll(),
                ),
                secondLoading(),
              ],
            )));
  }

  List<Widget> setAll() {
    if (isAdmin && !widget.history) {
      return [
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
            // new GestureDetector(
            //   child: new Text(
            //     "FLOOR",
            //     style: TextStyle(
            //       color: UIData.blue,
            //       fontSize: UIData.fontSize20,
            //     ),
            //   ),
            // ),
            // new Padding(
            //   padding: EdgeInsets.all(12.0),
            // ),
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
        streamOfRequests(),
      ];
    } else {
      return [
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
            // new GestureDetector(
            //   child: new Text(
            //     "FLOOR",
            //     style: TextStyle(
            //       color: UIData.blue,
            //       fontSize: UIData.fontSize20,
            //     ),
            //   ),
            // ),
            // new Padding(
            //   padding: EdgeInsets.all(12.0),
            // ),
            new Text(
              "${game.info}",
              style: new TextStyle(color: UIData.blackOrWhite),
            ),
          ],
        ),
        streamOfPosts(),
        setPlayersOrResult(),
        setQueueOrPayouts(),
      ];
    }
  }

  Widget setRequests() {
    if (isAdmin && !widget.history) {
      return streamOfRequests();
    } else {
      return null;
    }
  }

  moneyInPlay() {
    if (game.showMoneyOnTable && game.isRunning && !widget.history) {
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

  FloatingActionButton floatingActionButton() {
    if (!widget.history && !game.stopReg || hasJoined) {
      return FloatingActionButton(
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

  Future<Null> updateMoneyOnTable() async {
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
    if (full == true && !removed) {
      setQueue();
    } else if (!removed) {
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
        int requestAmount = 0;
        if (isAdmin) {
          QuerySnapshot qSnap = await firestoreInstance
              .collection("$gamePath/requests")
              .getDocuments();
          qSnap.documents.isNotEmpty
              ? requestAmount = qSnap.documents.length
              : requestAmount = 0;
        }

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
          0,
          docSnap.data["floor"],
          docSnap.data["floorfcm"],
          docSnap.data["floorname"],
          requestAmount,
          docSnap.data["stopreg"],
        );

        if (game.calculatePayouts == true && widget.history == true) {
          queueOrCalculateIcon = Icons.attach_money;
          queueOrCalculateString = "Payouts";
        }
        updateMoneyOnTable();
        checkIfFull();
        userFound = true;
        setScreen();
      } else
        Navigator.of(context).pop();
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

  void calculatePayouts() async {
    setState(() {
      isLoading = true;
    });
    payoutRequests.clear();
    List<PayoutPlayer> negativeList = <PayoutPlayer>[];
    List<PayoutPlayer> positiveList = <PayoutPlayer>[];

    // Delete previous payouts in db
    firestoreInstance
        .collection("$gamePath/payouts")
        .getDocuments()
        .then((qSnap) {
      qSnap.documents.forEach((doc) => firestoreInstance
          .document("$gamePath/payouts/${doc.documentID}")
          .delete());
    });

    // Get all players
    firestoreInstance
        .collection("$gamePath/players")
        .getDocuments()
        .then((playerDocs) {
      playerDocs.documents.forEach((doc) {
        // Sort players into lists negative and positive result
        int payout = doc.data["payout"];
        int buyin = doc.data["buyin"];

        if (buyin == 0 && payout == 0) {
        } else if (buyin > payout) {
          negativeList.add(PayoutPlayer(
            name: doc.data["name"],
            payOrPaidAmount: buyin - payout,
          ));
        } else {
          positiveList.add(PayoutPlayer(
            name: doc.data["name"],
            payOrPaidAmount: payout - buyin,
          ));
        }
      });

      PayoutPlayer pay;
      PayoutPlayer paid;

      while (negativeList.isNotEmpty || positiveList.isNotEmpty) {
        // Find player with biggest the loss
        for (PayoutPlayer player in negativeList) {
          if (positiveList.isEmpty) {
            payoutRequests.add(PayoutRequest(
              personNegative: player.name,
              hasLeft: true,
              payout: player.payOrPaidAmount,
            ));
          } else if (pay == null) {
            pay = player;
          } else if (pay.payOrPaidAmount < player.payOrPaidAmount) {
            pay = player;
          }
        }

        // Find player with the biggest win
        for (PayoutPlayer player in positiveList) {
          if (negativeList.isEmpty) {
            payoutRequests.add(PayoutRequest(
              personPositive: player.name,
              isMissing: true,
              payout: player.payOrPaidAmount,
            ));
          } else if (paid == null) {
            paid = player;
          } else if (paid.payOrPaidAmount < player.payOrPaidAmount) {
            paid = player;
          }
        }

        // If either list is empty at this point then everything has been handled and the loop should break after passing the data
        if (negativeList.isEmpty || positiveList.isEmpty) {
          for (PayoutRequest req in payoutRequests) {
            firestoreInstance.collection("$gamePath/payouts").add({
              "payout": req.payout,
              "personNegative": req.personNegative,
              "personPositive": req.personPositive,
              "hasLeft": req.hasLeft,
              "isMissing": req.isMissing,
            });
          }
          setState(() {
            isLoading = false;
          });
          break;
        }

        int tx = paid.payOrPaidAmount - pay.payOrPaidAmount;
        int txPayout;

        // Match up the two players, the one with the loss pays the one with the win and add the data to a payoutRequest obj.
        if (pay != null && paid != null) {
          tx.isNegative
              ? txPayout = paid.payOrPaidAmount
              : txPayout = pay.payOrPaidAmount;

          if (tx == 0) {
            txPayout = paid.payOrPaidAmount;
          }

          payoutRequests.add(PayoutRequest(
            payout: txPayout,
            personNegative: pay.name,
            personPositive: paid.name,
          ));

          if (tx.isNegative) {
            negativeList
                .firstWhere((p) => p.name == pay.name, orElse: () => null)
                .payOrPaidAmount -= txPayout;
            positiveList.remove(paid);
          } else if (!tx.isNegative && tx != 0) {
            positiveList
                .firstWhere((p) => p.name == paid.name, orElse: () => null)
                .payOrPaidAmount -= txPayout;
            negativeList.remove(pay);
          } else if (tx == 0) {
            negativeList.remove(pay);
            positiveList.remove(paid);
          }
          pay = null;
          paid = null;
        }
      }
    });
  }

  Widget addImage(String url) {
    if (url != null) {
      return new CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(url),
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
    Color color = UIData.blackOrWhite;
    if (document.documentID == widget.user.id) {
      color = UIData.blue;
    }
    return new Slidable(
      enabled: isAdmin,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
          leading: addImage(document.data["profilepicurl"]),
          title: new Text(
            document.data["name"],
            style: new TextStyle(fontSize: 25.0, color: color),
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
    Color color = UIData.blackOrWhite;
    if (document.documentID == widget.user.id) {
      color = UIData.blue;
    }
    return new Slidable(
      enabled: isAdmin,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
          leading: addImage(document.data["profilepicurl"]),
          title: new Text(
            document.data["name"],
            style: new TextStyle(fontSize: 25.0, color: color),
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
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Remove',
            color: UIData.red,
            icon: Icons.delete,
            onTap: () {
              firestoreInstance
                  .document("$gamePath/activeplayers/${document.documentID}")
                  .delete();
              firestoreInstance
                  .document("$gamePath/players/${document.documentID}")
                  .delete();
              checkIfFull();
              Log().postLogToCollection(
                  "$currentUserName removed ${widget.user.userName} from the game",
                  "$gamePath/log",
                  "Remove");
            }),
      ],
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

  Widget payoutsList() {
    Widget payoutBtn = Container(
      height: 12,
    );
    if (widget.group.admin) {
      payoutBtn = Padding(
        padding: EdgeInsets.only(top: 12, bottom: 12),
        child: PrimaryButton(
          color: UIData.yellowOrWhite,
          text: "Calculate payouts",
          onPressed: () => calculatePayouts(),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          payoutBtn,
          Column(
            children: payoutRequests.map((r) {
              if (r.hasLeft != null) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${r.personNegative} has ${r.payout} left to pay",
                      style: TextStyle(color: UIData.red, fontSize: 20.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              } else if (r.isMissing != null) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${r.personPositive} is missing ${r.payout}",
                      style: TextStyle(color: UIData.red, fontSize: 20.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              } else {
                return Container(
                  height: ServiceProvider.instance.screenService
                      .getPortraitHeightByPercentage(context, 10),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 3,
                      color: UIData.listColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                width: ServiceProvider.instance.screenService
                                    .getPortraitWidthByPercentage(context, 30),
                                child: Text(
                                  r.personNegative,
                                  style: TextStyle(
                                      color: UIData.red, fontSize: 20.0),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Container(
                                width: ServiceProvider.instance.screenService
                                    .getPortraitWidthByPercentage(context, 30),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: UIData.blackOrWhite,
                                ),
                              ),
                              Container(
                                width: ServiceProvider.instance.screenService
                                    .getPortraitWidthByPercentage(context, 30),
                                child: Text(
                                  r.personPositive,
                                  style: TextStyle(
                                      color: UIData.green, fontSize: 20.0),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Amount: ${r.payout} ",
                            style: TextStyle(
                                color: UIData.blackOrWhite, fontSize: 20.0),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }).toList(),
          )
        ],
      ),
    );

    // return ListTile(
    //   dense: true,
    //   title: Row(
    //     // crossAxisAlignment: CrossAxisAlignment.end,
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: <Widget>[
    //       Text(
    //         "${document.data["personnegative"]} ",
    //         style: TextStyle(color: UIData.red, fontSize: 20.0),
    //         overflow: TextOverflow.ellipsis,
    //       ),

    //       // Icon(Icons.arrow_forward, color: UIData.blackOrWhite,),
    //       Text(
    //         "${document.data["personpositive"]} ",
    //         style: TextStyle(color: UIData.green, fontSize: 20.0),
    //         overflow: TextOverflow.ellipsis,
    //         // textAlign: TextAlign.center,
    //       ),
    //     ],
    //   ),
    //   contentPadding: EdgeInsets.all(10.0),
    //   subtitle: Text(
    //     "${document.data["sentence"]}",
    //     // overflow: TextOverflow.ellipsis,
    //     textAlign: TextAlign.center,

    //     style: TextStyle(
    //         color: UIData.blackOrWhite,
    //         fontSize: UIData.fontSize16,
    //         letterSpacing: .50),
    //   ),
    // );
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
    Color color = UIData.blackOrWhite;
    if (document.documentID == widget.user.id) {
      color = UIData.blue;
    }
    return new Slidable(
      enabled: isAdmin,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
            leading: addImage(document.data["profilepicurl"]),
            title: new Text(
              document.data["name"],
              style: new TextStyle(fontSize: 25.0, color: color),
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
                  "$currentUserName removed ${document.data["name"]} from the queue",
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

  Widget setPlayersOrResult() {
    if (widget.history == true) {
      return resultStream();
    } else {
      return registered();
    }
  }

  Widget setQueueOrPayouts() {
    if (widget.history == true) {
      return payoutsList();
    } else {
      return queue();
    }
  }

  Widget _resultList(BuildContext context, DocumentSnapshot document) {
    Color colorName = UIData.blackOrWhite;
    if (document.documentID == widget.user.id) {
      colorName = UIData.blue;
    }
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
      enabled: isAdmin,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
            leading: addImage(document.data["profilepicurl"]),
            title: new Text(
              "${document.data["name"]} ",
              style: new TextStyle(fontSize: 24.0, color: colorName),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: new Text(
              "$result",
              style: new TextStyle(fontSize: 18.0, color: color),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => pushPlayerPage(
                document.documentID,
                document.data["buyin"],
                document.data["payout"],
                document.data["name"],
                document.data["profilepicurl"],
                false)),
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
            .orderBy("payout", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 60.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _resultList(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget _buildStreamOfPosts(BuildContext context, DocumentSnapshot document) {
    return new Slidable(
      enabled: isAdmin,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
          dense: true,
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                "${document.data["name"]} ",
                style: new TextStyle(color: UIData.blue, fontSize: 20.0),
                overflow: TextOverflow.ellipsis,
              ),
              new Row(
                children: <Widget>[
                  new Text(
                    "${document.data["dayofweek"]} ${document.data["time"]} ${document.data["date"]}",
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(color: Colors.grey[600]),
                  ),
                  reportButton(document),
                ],
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
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Delete',
            color: UIData.red,
            icon: Icons.delete,
            onTap: () {
              firestoreInstance
                  .document("$gamePath/posts/${document.documentID}")
                  .delete();

              Log().postLogToCollection(
                  "${widget.user.userName} has deleted post: ${document.data["body"]}",
                  "$gamePath/log",
                  "Post");
            }),
      ],
    );
  }

  Widget reportButton(DocumentSnapshot document) {
    if (widget.group.admin) {
      return new Container();
    } else {
      return new IconButton(
        icon: Icon(
          Icons.more_vert,
          color: UIData.blackOrWhite,
        ),
        onPressed: () {
          ReportDialog reportDialog = new ReportDialog(
            reportedById: widget.user.id,
            reportedId: widget.group.id,
            type: "gamepost",
            text: "Report post",
            postId: game.id.toString(),
          );
          showDialog(context: context, child: reportDialog);
        },
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

  Widget _buildStreamOfRequests(
      BuildContext context, DocumentSnapshot document) {
    String buyinText = " of ${document.data["addbuyin"]}${game.currency}";
    if (document.data["type"] == "payout") {
      buyinText = "";
    }
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
          title: new Text(
            "${document.data["name"]} has requested a ${document.data["type"]}$buyinText",
            style: new TextStyle(fontSize: 18.0, color: UIData.blackOrWhite),
          ),
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Confirm',
            color: UIData.green,
            icon: Icons.check_circle_outline,
            onTap: () async {
              String logText;
              setState(() {
                game.requestAmount -= 1;
              });
              if (document.data["type"] == "payout") {
                removePlayer(document.data["id"], true, document.data["name"]);
                Essentials().showSnackBar(
                    "${document.data["name"]} is ready for payout and has been removed from active players",
                    formKey.currentState.context);
                logText =
                    "${widget.user.userName} has granted ${document.data["name"]} a payout";
              } else {
                int newBuyin =
                    document.data["currentbuyin"] + document.data["addbuyin"];
                await firestoreInstance.runTransaction((tx) async {
                  DocumentReference docRef = firestoreInstance
                      .document("$gamePath/players/${document.data["id"]}");
                  DocumentSnapshot docSnap = await tx.get(docRef);
                  await tx.update(docRef, {
                    "buyin": docSnap.data["buyin"] + document.data["addbuyin"],
                  });
                });
                firestoreInstance
                    .document("$gamePath/activeplayers/${document.data["id"]}")
                    .updateData({
                  "buyin": newBuyin,
                });

                Essentials().showSnackBar(
                    "Buyin for player ${document.data["name"]} has been updated, from ${document.data["currentbuyin"]} to $newBuyin",
                    formKey.currentState.context);

                logText =
                    "${widget.user.userName} has granted ${document.data["name"]} a ${document.data["type"]} of ${document.data["addbuyin"]}";
              }
              Log().postLogToCollection(logText, "$gamePath/log", "Request");
              firestoreInstance
                  .document("$gamePath/requests/${document.documentID}")
                  .delete();
            }),
        new IconSlideAction(
            caption: 'Dismiss',
            color: UIData.red,
            icon: Icons.delete,
            onTap: () {
              setState(() {
                game.requestAmount -= 1;
              });
              firestoreInstance
                  .document("$gamePath/requests/${document.documentID}")
                  .delete();

              Log().postLogToCollection(
                  "${widget.user.userName} has dismissed a ${document.data["type"]} request from ${document.data["name"]}",
                  "$gamePath/log",
                  "Request");
            }),
      ],
    );
  }

  Widget streamOfRequests() {
    return StreamBuilder(
        stream: Firestore.instance.collection("$gamePath/requests").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return loading();
          else {
            game.requestAmount = snapshot.data.documents.length;
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) => _buildStreamOfRequests(
                  context, snapshot.data.documents[index]),
            );
          }
        });
  }
}

// Used to hold player info when calculating payouts
class PayoutPlayer {
  PayoutPlayer({
    this.payOrPaidAmount,
    @required this.name,
  });

  int payOrPaidAmount;
  final String name;
}

class PayoutRequest {
  PayoutRequest({
    this.payout,
    this.personNegative,
    this.personPositive,
    this.hasLeft,
    this.isMissing,
  });
  final bool isMissing;
  final bool hasLeft;
  final String personNegative;
  final String personPositive;
  final int payout;
}
