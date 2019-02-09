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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yadda/objects/prizePool.dart';
import 'package:yadda/widgets/primary_button.dart';

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

class TournamentPageState extends State<TournamentPage>
    with TickerProviderStateMixin {
  static final formKey = new GlobalKey<FormState>();

  final Firestore firestoreInstance = Firestore.instance;
  TabController _tabController;

  String currentUserId;
  String currentUserName;

  String groupId;
  String logPath;
  String gamePath;

  String playerName;
  String host;
  String joinLeave = "";

  bool isAdmin = false;
  bool userFound = false;
  bool full = false;
  bool isLoading = false;
  bool hasJoined;
  bool isScrollable = false;

  IconData playerOrResultsIcon = Icons.people;
  double playerOrResultsIconSize = 30;
  String playerOrResultsString = "Active";
  String tournamentActiveOrHistory = "tournamentactive";

  Color color;
  Color red = UIData.red;
  Color green = UIData.green;
  Color blue = UIData.blue;

  Game game;

  @override
  initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 4);
    list.add(new Container());
    currentUserId = widget.user.id;
    currentUserName = widget.user.userName;
    groupId = widget.group.id;

    isAdmin = widget.group.admin;

    if (isAdmin == true) {
      if (!widget.history) {
        _tabController = new TabController(vsync: this, length: 6);
        isScrollable = true;
      }
    } else {
      _tabController = new TabController(vsync: this, length: 4);
    }
    if (widget.history == true) {
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
            removePlayer(widget.user.id, false, widget.user.userName);
          } else if (hasJoined == false &&
              game.registeredPlayers < game.maxPlayers) {
            addPlayer();
          }
        },
      );
    }
    return null;
  }

  checkIfFull() async {
    if (game != null) {
      try {
        QuerySnapshot qSnap = await firestoreInstance
            .collection("$gamePath/players")
            .getDocuments();
        if (qSnap.documents.isNotEmpty) {
          int p = 0;
          qSnap.documents.forEach((doc) {
            if (doc.data["active"]) {
              p += 1;
            }
          });
          game.setRegisteredPlayers(p);
        } else {
          game.setRegisteredPlayers(0);
        }
        game.setGameRegisteredPlayers(gamePath);
        checkPlayerGameStatus();
      } catch (e) {}
    }
  }

  checkPlayerGameStatus() async {
    DocumentSnapshot dSnap = await firestoreInstance
        .document("$gamePath/players/$currentUserId")
        .get();
    if (dSnap.exists && dSnap.data["active"]) {
      hasJoined = true;
      setLeave();
    } else if (hasJoined != true && game.registeredPlayers >= game.maxPlayers) {
      full = true;
      setFull();
    } else {
      hasJoined = false;
      setJoin();
    }
  }

  addPlayer() async {
    hasJoined = true;
    setLeave();
    checkIfFull();
    DocumentReference docRef =
        firestoreInstance.document("$gamePath/players/$currentUserId");
    DocumentSnapshot docSnap = await docRef.get();
    if (!docSnap.exists) {
      firestoreInstance.runTransaction((Transaction tx) async {
        await firestoreInstance
            .document("$gamePath/players/$currentUserId")
            .setData({
          'name': currentUserName,
          'id': currentUserId,
          "placing": game.maxPlayers,
          'payout': 0,
          'rebuy': 0,
          'addon': 0,
          "profilepicurl": widget.user.profilePicURL,
          "active": true,
        });
      });
    } else {
      docRef.updateData({
        "active": true,
      });
    }
    Log()
        .postLogToCollection("$currentUserName joined game", logPath, "Joined");
  }

  removePlayer(String uid, bool removed, String userName) async {
    String removedType;
    String removedText;
    if (removed) {
      removedType = "Removed";
      removedText = "$userName has been removed from the game";
    } else {
      removedType = "Left";
      removedText = "$userName has left the game";
    }
    hasJoined = false;
    setJoin();
    DocumentReference docRef =
        firestoreInstance.document("$gamePath/players/$uid");
    if (!game.isRunning) {
      await docRef.delete();
    } else {
      docRef.updateData({
        "active": false,
      });
    }
    checkIfFull();
    Log().postLogToCollection(removedText, logPath, removedType);
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
          0,
          docSnap.data["buyin"],
          docSnap.data["date"],
          docSnap.data["gametype"],
          docSnap.data["maxplayers"],
          docSnap.data["orderbytime"],
          docSnap.data["rebuy"],
          docSnap.data["registeredplayers"],
          0,
          docSnap.data["startingchips"],
          docSnap.data["time"],
          docSnap.data["calculatepayouts"],
          docSnap.data["currency"],
          docSnap.data["isrunning"],
          docSnap.data["moneyontable"],
          false,
          1,
          docSnap.data["floor"],
          docSnap.data["floorfcm"],
          docSnap.data["floorname"],
          docSnap.data["stopreg"],
          rebuyPrice: docSnap.data["rebuyprice"],
          addonPrice: docSnap.data["addonprice"],
        );
        populatePPList();
        checkIfFull();
        userFound = true;
        setScreen();
      }
    });
  }

  Widget newPostButton() {
    if (isAdmin) {
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
        icon: Icon(
          Icons.person,
          color: UIData.appBarColor,
          size: 0,
        ),
        onPressed: null,
      );
    }
  }

  Widget settingsButton() {
    if (isAdmin) {
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
        icon: Icon(
          Icons.person,
          color: UIData.appBarColor,
          size: 0,
        ),
        onPressed: null,
      );
    }
  }

  Scaffold page() {
    return Scaffold(
        floatingActionButton: floatingActionButton(),
        backgroundColor: UIData.dark,
        appBar: AppBar(
            iconTheme: IconThemeData(color: UIData.blackOrWhite),

            // centerTitle: true,
            actions: <Widget>[
              newPostButton(),
              settingsButton(),
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
            ],
            backgroundColor: UIData.appBarColor,
            bottom: TabBar(
              isScrollable: isScrollable,
              controller: _tabController,
              tabs: tabs(),
            ),
            title: new Align(
                alignment: Alignment.center,
                child: new Text(
                  game.name,
                  style: new TextStyle(
                      color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
                ))),
        body: new Form(
            key: formKey,
            child: Stack(
              children: <Widget>[
                TabBarView(
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
            rebuy(),
            addon(),
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
            new Text(
              "Currency: ${game.currency}",
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
        prizePoolPage(),
        playerList(),
        streamOfRequests(),
      ];
    } else {
      return [
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
            rebuy(),
            addon(),
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
            new Text(
              "Currency: ${game.currency}",
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
                fontWeight: FontWeight.bold, color: UIData.blackOrWhite),
          ),
        ),
      ];
    }
  }

  calculatePayouts() async {
    int totalPPAmount = 0;
    int totalAddons = 0;
    int totalRebuys = 0;
    QuerySnapshot qSnap =
        await firestoreInstance.collection("$gamePath/players").getDocuments();
    qSnap.documents.forEach((doc) {
      int r = doc.data["rebuy"];
      int a = doc.data["addon"];
      totalRebuys += r;
      totalAddons += a;
      int rAmount = game.rebuyPrice * r;
      int aAmount = game.addonPrice * a;
      totalPPAmount += rAmount + aAmount + game.buyin;
    });
    calcRebuys = totalRebuys;
    calcAddons = totalAddons;
    calcBuyins = qSnap.documents.length;
    preCalculation();
    allPayouts(qSnap.documents.length, totalPPAmount);
  }

  List<Widget> list = new List();

  allPayouts(int count, int pp) {
    PrizePoolList poolList = new PrizePoolList(count);
    list = new List();

    for (int i = 0; i < poolList.list.length; i++) {
      double doobs = (poolList.list[i] / 100);
      double doobsAmount = pp * doobs;
      int amount = doobsAmount.round();
      ListTile tile = new ListTile(
        leading: new Text(
          "${i + 1}.",
          style: new TextStyle(color: UIData.blackOrWhite, fontSize: 24),
        ),
        title: new Text(
          "$amount ${game.currency}",
          style: new TextStyle(color: UIData.blackOrWhite),
          textAlign: TextAlign.center,
        ),

        // new Text(
        //   "$amount",
        //   style: new TextStyle(color: UIData.blackOrWhite),
        // ),
        trailing: new Text(
          "${poolList.list[i]}%",
          style: new TextStyle(color: UIData.blackOrWhite),
        ),
      );
      list.add(tile);
    }
    setState(() {
      populatePPList();
    });
  }

  Widget prizePoolPage() {
    if (isAdmin) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: new Column(
          children: <Widget>[
            new Text(
              "PRIZE POOL",
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize24),
            ),
            new Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: new PrimaryButton(
                  text: "Calculate payouts",
                  onPressed: () {
                    calculatePayouts();
                    game.calculatePayouts = true;
                    firestoreInstance.document(gamePath).updateData({
                      "calculatepayouts": game.calculatePayouts,
                    });
                  }),
            ),
            preCalculation(),
            new Column(
              children: list,
            )
          ],
        ),
      );
    }
  }

  int calcBuyins = 0;
  int calcRebuys = 0;
  int calcAddons = 0;

  List<Widget> prizePoolList;

  void populatePPList() {
    prizePoolList = new List();
    prizePoolList.add(
      new Text(
        "Type",
        style: new TextStyle(color: UIData.blue),
        textAlign: TextAlign.left,
      ),
    );
    prizePoolList.add(
      new Text(
        "Amount",
        style: new TextStyle(color: UIData.blue),
        textAlign: TextAlign.center,
      ),
    );
    prizePoolList.add(
      new Text("Sum",
          style: new TextStyle(color: UIData.blue), textAlign: TextAlign.right),
    );
    prizePoolList.add(
      new Text(
        "Buy ins",
        style: new TextStyle(color: UIData.blackOrWhite),
        textAlign: TextAlign.left,
      ),
    );
    prizePoolList.add(
      new Text("$calcBuyins",
          style: new TextStyle(color: UIData.blackOrWhite),
          textAlign: TextAlign.center),
    );
    prizePoolList.add(
      new Text("${calcBuyins * game.buyin}",
          style: new TextStyle(color: UIData.blackOrWhite),
          textAlign: TextAlign.right),
    );

    if (game.rebuy > 0) {
      prizePoolList.add(
        new Text(
          "Rebuys",
          style: new TextStyle(color: UIData.blackOrWhite),
          textAlign: TextAlign.left,
        ),
      );
      prizePoolList.add(
        new Text("$calcRebuys",
            style: new TextStyle(color: UIData.blackOrWhite),
            textAlign: TextAlign.center),
      );
      prizePoolList.add(
        new Text("${calcRebuys * game.rebuyPrice}",
            style: new TextStyle(color: UIData.blackOrWhite),
            textAlign: TextAlign.right),
      );
    }
    if (game.addon > 0) {
      prizePoolList.add(
        new Text(
          "Addons",
          style: new TextStyle(color: UIData.blackOrWhite),
          textAlign: TextAlign.left,
        ),
      );
      prizePoolList.add(
        new Text("$calcAddons",
            style: new TextStyle(color: UIData.blackOrWhite),
            textAlign: TextAlign.center),
      );
      prizePoolList.add(
        new Text("${calcAddons * game.rebuyPrice}",
            style: new TextStyle(color: UIData.blackOrWhite),
            textAlign: TextAlign.right),
      );
    }
    prizePoolList.add(
      new Text(
        "Totals",
        style: new TextStyle(color: UIData.blackOrWhite),
        textAlign: TextAlign.left,
      ),
    );
    prizePoolList.add(
      new Text("${calcAddons + calcRebuys + calcBuyins}",
          style: new TextStyle(color: UIData.blackOrWhite),
          textAlign: TextAlign.center),
    );
    prizePoolList.add(
      new Text(
          "${(calcAddons * game.addonPrice) + (calcRebuys * game.rebuyPrice) + (calcBuyins * game.buyin)}",
          style: new TextStyle(color: UIData.blackOrWhite),
          textAlign: TextAlign.right),
    );
    setState(() {});
  }

  Widget preCalculation() {
    if (game.calculatePayouts) {
      return new Container(
          decoration: new BoxDecoration(
              color: UIData.listColor,
              border: Border.all(color: Colors.grey[600]),
              borderRadius: new BorderRadius.all(const Radius.circular(8.0))),
          child: new Padding(
              padding: EdgeInsets.all(8.0),
              child: new Column(
                children: <Widget>[
                  GridView.count(
                      shrinkWrap: true,
                      childAspectRatio: 4,
                      crossAxisCount: 3,
                      children: prizePoolList),
                ],
              )));
    } else {
      return new Container();
    }
  }

  List<Widget> tabs() {
    if (isAdmin && !widget.history) {
      return [
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
        Tab(
          icon: Icon(
            Icons.group,
            color: UIData.yellowOrWhite,
            size: 30.0,
          ),
          text: "All",
        ),
        Tab(
          icon: Icon(
            Icons.notification_important,
            color: UIData.red,
            size: 30.0,
          ),
          text: "Requests",
        ),
      ];
    } else {
      return [
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
      ];
    }
  }

  Widget rebuy() {
    if (game.rebuy > 0) {
      return new Text(
        "Rebuy: ${game.rebuy} Price: ${game.rebuyPrice}",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: UIData.blackOrWhite),
      );
    } else {
      return new Container();
    }
  }

  Widget addon() {
    if (game.addon > 0) {
      return new Text(
        "Addon: ${game.addon} Price: ${game.addonPrice}",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: UIData.blackOrWhite),
      );
    } else {
      return new Container();
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
      return activePlayerList();
    }
  }

  pushPlayerPage(String id, int placing, int addon, int rebuy, int payout,
      String name, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TournamentPlayerPage(
                game: game,
                url: url,
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

  Widget _activePlayerListItems(
      BuildContext context, DocumentSnapshot document) {
    Color color = UIData.blackOrWhite;
    if (document.documentID == widget.user.id) {
      color = UIData.blue;
    }
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
          leading: addImage(document.data["profilepicurl"]),
          title: new Text(
            document.data["name"],
            style: new TextStyle(fontSize: 24.0, color: color),
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => pushPlayerPage(
              document.documentID,
              document.data["placing"],
              document.data["addon"],
              document.data["rebuy"],
              document.data["payout"],
              document.data["name"],
              document.data["profilepicurl"]),
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Remove',
            color: UIData.red,
            icon: Icons.delete,
            onTap: () {
              removePlayer(document.documentID, true, document.data["name"]);
            }),
      ],
    );
  }

  Widget activePlayerList() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection("$gamePath/players")
            .where("active", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 60.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _activePlayerListItems(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget _playerListItems(BuildContext context, DocumentSnapshot document) {
    Color color = UIData.blackOrWhite;
    if (document.documentID == widget.user.id) {
      color = UIData.blue;
    }
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
          leading: addImage(document.data["profilepicurl"]),
          title: new Text(
            document.data["name"],
            style: new TextStyle(fontSize: 24.0, color: color),
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => pushPlayerPage(
              document.documentID,
              document.data["placing"],
              document.data["addon"],
              document.data["rebuy"],
              document.data["payout"],
              document.data["name"],
              document.data["profilepicurl"]),
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: 'Remove',
          color: UIData.red,
          icon: Icons.delete,
          onTap: () => firestoreInstance
              .document("$gamePath/players/${document.documentID}")
              .delete(),
        ),
      ],
    );
  }

  Widget playerList() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection("$gamePath/players")
            .orderBy("name")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 60.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _playerListItems(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget _resultList(BuildContext context, DocumentSnapshot document) {
    Color color = UIData.blackOrWhite;
    if (document.documentID == widget.user.id) {
      color = UIData.blue;
    }
    return ListTile(
      leading: new Text(
        "${document.data["placing"]}.",
        style: new TextStyle(fontSize: 24.0, color: color),
        overflow: TextOverflow.ellipsis,
      ),
      title: new Text(
        "${document.data["name"]} ",
        style: new TextStyle(fontSize: 24.0, color: color),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: new Text(
        "Payout: ${document.data["payout"]}",
        style: new TextStyle(fontSize: 18.0, color: color),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => pushPlayerPage(
          document.documentID,
          document.data["placing"],
          document.data["addon"],
          document.data["rebuy"],
          document.data["payout"],
          document.data["name"],
          document.data["profilepicurl"]),
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
    return new Slidable(
      enabled: isAdmin,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
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

  Widget _buildStreamOfRequests(
      BuildContext context, DocumentSnapshot document) {
    String an;
    document.data["type"] == "addon" ? an = "an" : an = "a";
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: new ListTile(
          title: new Text(
            "${document.data["name"]} has requested $an ${document.data["type"]}",
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
              firestoreInstance
                  .document("$gamePath/requests/${document.documentID}")
                  .delete();
              Log().postLogToCollection(
                  "${widget.user.userName} granted ${document.data["name"]} $an ${document.data["type"]}",
                  "$gamePath/log",
                  "Request");
              await firestoreInstance.runTransaction((tx) async {
                DocumentReference docRef = firestoreInstance
                    .document("$gamePath/players/${document.data["id"]}");
                DocumentSnapshot docSnap = await tx.get(docRef);
                await tx.update(docRef, {
                  document.data["type"]:
                      docSnap.data["${document.data["type"]}"] + 1,
                });
              });
            }),
        new IconSlideAction(
            caption: 'Dismiss',
            color: UIData.red,
            icon: Icons.delete,
            onTap: () {
              firestoreInstance
                  .document("$gamePath/requests/${document.documentID}")
                  .delete();

              Log().postLogToCollection(
                  "${widget.user.userName} has dismissed $an ${document.data["type"]} from ${document.data["name"]}",
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
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) => _buildStreamOfRequests(
                  context, snapshot.data.documents[index]),
            );
          }
        });
  }
}
