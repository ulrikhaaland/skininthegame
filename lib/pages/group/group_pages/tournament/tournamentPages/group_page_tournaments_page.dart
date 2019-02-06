import 'package:flutter/material.dart';
import 'package:yadda/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/pages/group/new/newTournament_page.dart';
import 'package:yadda/pages/group/group_pages/tournament/tournamentPages/tournament_page.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/pages/inAppPurchase/consumeable.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yadda/utils/delete.dart';

class GroupTournaments extends StatefulWidget {
  const GroupTournaments({
    Key key,
    this.user,
    this.groupType,
    this.auth,
    this.group,
  }) : super(key: key);
  final BaseAuth auth;
  final User user;
  final Group group;
  final String groupType;

  @override
  GroupTournamentsState createState() => GroupTournamentsState();
}

class GroupTournamentsState extends State<GroupTournaments>
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

  @override
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
          centerTitle: true,
          iconTheme: IconThemeData(color: UIData.blackOrWhite),
          title: new Align(
              child: new Text(
            "Tournaments",
            style: new TextStyle(
                fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
          )),
          actions: <Widget>[
            plussButton(),
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
          ],
          backgroundColor: UIData.appBarColor,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.play_circle_outline,
                  color: UIData.blackOrWhite,
                  size: 30,
                ),
                text: "Active",
              ),
              Tab(
                icon: Icon(
                  Icons.restore,
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
    if (widget.group.admin) {
      return new IconButton(
          icon: new Icon(
            Icons.add_circle_outline,
            size: UIData.iconSizeAppBar,
            color: UIData.blackOrWhite,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewTournament(
                        user: widget.user,
                        group: widget.group,
                        fromTournamentGroupPage: fromTournamentGroupPage,
                      )),
            );
          });
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
            Icons.whatshot,
            color: Color.lerp(
                Colors.green, Colors.red, document.data["buyin"] / 1000),
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
                "Buyin: ${document.data["buyin"]}",
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
                  builder: (context) => TournamentPage(
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
            onTap: () {
              setState(() {
                enabled = false;
              });
              Delete().deleteGame(
                  "groups/${widget.group.id}/games/type/tournamentactive/${document.data["id"]}",
                  false);
            }),
      ],
    );
  }

  Widget activeTournament() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("groups/$groupId/games/type/tournamentactive")
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
          // dense: true,
          enabled: enabled,
          contentPadding: EdgeInsets.all(3.0),
          leading: new Icon(
            Icons.whatshot,
            color: Color.lerp(
                Colors.green, Colors.red, document.data["buyin"] / 1000),
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
                "Buyin: ${document.data["buyin"]}",
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
                  builder: (context) => TournamentPage(
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
            onTap: () {
              setState(() {
                enabled = false;
              });
              Delete().deleteGame(
                  "groups/${widget.group.id}/games/type/tournamenthistory/${document.data["id"]}",
                  false);
            }),
      ],
    );
  }

  Widget historyTournaments() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("groups/$groupId/games/type/tournamenthistory")
            .orderBy("orderbytime", descending: false)
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

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }
}
