import 'package:flutter/material.dart';
import 'package:yadda/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:flutter/foundation.dart';
import 'cashgame_page.dart';
import '../../new/newCashGame_page.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_functions/cloud_functions.dart';

class GroupCashGames extends StatefulWidget {
  const GroupCashGames({
    Key key,
    this.user,
    this.groupType,
    this.group,
  }) : super(key: key);
  final User user;
  final Group group;
  final String groupType;

  @override
  GroupCashGamesState createState() => GroupCashGamesState();
}

class GroupCashGamesState extends State<GroupCashGames>
    with TickerProviderStateMixin {
  final bool newGroupOption = true;

  TabController _tabController;

  final BaseAuth auth = Auth();

  bool userFound = false;
  String currentUserId;
  bool getStatus = false;
  bool fromTournamentGroupPage = true;

  String type;
  String groupId;
  String gameId;
  int registeredPlayers;

  List<String> data = new List<String>();
  String currentUserName;
  String email;
  String uid;
  String onTapGroupId;

  initState() {
    super.initState();
    currentUserId = widget.user.id;
    groupId = widget.group.id;
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return page();
  }

  Scaffold page() {
    return Scaffold(
        backgroundColor: UIData.dark,
        appBar: AppBar(
          iconTheme: IconThemeData(color: UIData.blackOrWhite),
          title: new Text(
            "Cash Games",
            style: new TextStyle(
                fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
          ),
          actions: <Widget>[
            plussButton(),
          ],
          backgroundColor: UIData.appBarColor,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.play_arrow,
                  color: UIData.blackOrWhite,
                  size: 30,
                ),
                text: "Active",
              ),
              Tab(
                icon: Icon(
                  Icons.history,
                  color: Colors.grey[600],
                  size: 30,
                ),
                text: "History",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            activeTournament(),
            historyTournaments(),
          ],
        ));
  }

  Widget plussButton() {
    if (widget.group.admin == true) {
      return new Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: IconButton(
              icon: new Icon(
                Icons.add_circle_outline,
                size: UIData.iconSizeAppBar,
                color: UIData.blackOrWhite,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewCashGame(
                            user: widget.user,
                            group: widget.group,
                          )),
                );
              }));
    } else {
      return new FlatButton(onPressed: null, child: new Text(""));
    }
  }

  Widget _activeTournamentList(
      BuildContext context, DocumentSnapshot document) {
    String isRunning = "${document.data["date"]} - ${document.data["time"]}";
    Color color = UIData.blackOrWhite;
    if (document.data["isrunning"] == true) {
      isRunning = "Running";
      color = UIData.red;
    }
    bool enabled = true;
    return new Slidable(
      enabled: widget.group.admin,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: ListTile(
          enabled: enabled,
          contentPadding: EdgeInsets.all(3.0),
          leading: new Icon(
            Icons.attach_money,
            color: UIData.green,
            size: 40.0,
          ),
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                "${document.data["fittedname"]}",
                textAlign: TextAlign.start,
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
              new Text(
                isRunning,
                style: new TextStyle(color: color),
              )
            ],
          ),
          subtitle: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                "Blinds: ${document.data["sblind"]}/${document.data["bblind"]}",
                textAlign: TextAlign.start,
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
              new Text(
                "Players: ${document.data["registeredplayers"]}/${document.data["maxplayers"]}",
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
            ],
          ),
          onTap: () {
            gameId = document.documentID;
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CashGamePage(
                        user: widget.user,
                        group: widget.group,
                        gameId: gameId,
                        history: false,
                      )),
            );
          },
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Delete',
            color: UIData.red,
            icon: Icons.delete,
            onTap: () async {
              var resp = await CloudFunctions.instance
                  .call(functionName: 'recursiveDelete', parameters: {
                "path":
                    "groups/${widget.group.id}/games/type/cashgameactive/${document.documentID}",
              });
              print(resp);
              // resp
              // Delete().deleteGame(
              //     "groups/${widget.group.id}/games/type/cashgameactive/${document.data["id"]}",
              //     true);
            }),
      ],
    );
  }

  Widget activeTournament() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("groups/$groupId/games/type/cashgameactive")
            .orderBy("orderbytime", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 60.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _activeTournamentList(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget _historyTournamentList(
      BuildContext context, DocumentSnapshot document) {
    bool enabled = true;
    return new Slidable(
      enabled: widget.group.admin,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        child: ListTile(
          enabled: enabled,
          contentPadding: EdgeInsets.all(3.0),
          leading: new Icon(
            Icons.attach_money,
            color: UIData.green,
            size: 40.0,
          ),
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                "${document.data["fittedname"]}",
                textAlign: TextAlign.start,
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
              new Text(
                "${document.data["date"]} - ${document.data["time"]}",
                style: new TextStyle(color: UIData.blackOrWhite),
              )
            ],
          ),
          subtitle: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                "Blinds: ${document.data["sblind"]}/${document.data["bblind"]}",
                textAlign: TextAlign.start,
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
              new Text(
                "Players: ${document.data["registeredplayers"]}/${document.data["maxplayers"]}",
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
            ],
          ),
          onTap: () {
            gameId = document.documentID;
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CashGamePage(
                        history: true,
                        user: widget.user,
                        group: widget.group,
                        gameId: gameId,
                      )),
            );
          },
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Delete',
            color: UIData.red,
            icon: Icons.delete,
            onTap: () async {
              await CloudFunctions.instance
                  .call(functionName: 'recursiveDelete', parameters: {
                "path":
                    "groups/${widget.group.id}/games/type/cashgamehistory/${document.documentID}",
              });
            }),
      ],
    );
  }

  Widget historyTournaments() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("groups/$groupId/games/type/cashgamehistory")
            .orderBy("orderbytime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 60.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _historyTournamentList(context, snapshot.data.documents[index]),
          );
        });
  }

  returnGroupId() {
    return onTapGroupId;
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }
}
