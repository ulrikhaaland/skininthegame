import 'package:flutter/material.dart';
import 'package:yadda/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/pages/userSearch/search.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/user_profile/profile_page_alt.dart';

import 'package:yadda/pages/profile/profile_page.dart';
import 'package:yadda/objects/group.dart';

SearchBar searchBar;
bool _fresh = false;

AppBar _buildAppBar(BuildContext context) {
  return new AppBar(
    title: new Text("Søk etter medlemmer"),
    actions: <Widget>[
      searchBar.getSearchAction(context),
    ],
  );
}

class MembersPage extends StatefulWidget {
  const MembersPage({Key key, this.user, this.groupType, this.group})
      : super(key: key);
  final User user;
  final Group group;
  final String groupType;

  @override
  MembersPageState createState() => MembersPageState();
}

class MembersPageState extends State<MembersPage> {
  static final formKey = new GlobalKey<FormState>();

  final bool newGroupOption = true;
  final Firestore firestoreInstance = Firestore.instance;

  bool userFound = false;
  bool registeredGames = true;
  bool getStatus = false;
  bool noGroups = false;

  int numberOfCashGames = 0;
  int numberOfTournaments = 0;
  int screen = 0;
  int members = 0;

  String currentUserName;
  String currentUserId;
  String type;
  String groupId;
  String groupSearchName;

  List<String> data = new List<String>();
  String username;
  String email;
  String uid;
  String onTapGroupId;

  MembersPageState() {
    searchBar = new SearchBar(
      showClearButton: true,
      onSubmitted: onSubmitted,
      inBar: true,
      buildDefaultAppBar: _buildAppBar,
      setState: setState,
    );
  }

  initState() {
    super.initState();
    currentUserId = widget.user.id;
  }

  void onSubmitted(String value) {
    setState(() {
      groupSearchName = value;
      _fresh = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: UIData.dark,
        appBar: new AppBar(
          backgroundColor: UIData.appBarColor,
          iconTheme: IconThemeData(color: UIData.blackOrWhite),
          actions: <Widget>[],
          title: new Directionality(
            textDirection: Directionality.of(context),
            child: TextField(
              autocorrect: false,
              style: new TextStyle(color: UIData.blackOrWhite),
              decoration: InputDecoration(
                fillColor: UIData.blackOrWhite,
                labelText: 'Search for members',
                labelStyle: new TextStyle(color: Colors.grey[600]),
                icon: new Icon(
                  Icons.supervised_user_circle,
                  size: 40.0,
                  color: Colors.blue,
                ),
              ),
              onChanged: (String value) {
                groupSearchName = value.toLowerCase();
                if (screen == 0) {
                  setState(() {
                    screen = 1;

                    setScreen();
                  });
                } else if (value == "") {
                  setState(() {
                    screen = 0;

                    setScreen();
                  });
                } else if (screen == 1) {
                  setState(() {
                    setScreen();
                  });
                }
              },
            ),
          ),
        ),
        body: setScreen());
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  setScreen() {
    if (screen == 0) {
      return friendSearch();
    } else if (screen == 1) {
      return groupSearch();
    }
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      title: new Text(
        document.data["username"],
        style: new TextStyle(color: UIData.blackOrWhite),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        if (widget.group.admin == true &&
            document.data["uid"] != widget.group.host) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePageAlt(
                      user: widget.user,
                      profileUserName: document.data["username"],
                      profileUserId: document.data["uid"],
                      profileUserIsAdmin: document.data["admin"],
                      group: widget.group,
                    )),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(
                      user: widget.user,
                      profileId: document.data["uid"],
                    )),
          );
        }
      },
    );
  }

  Widget friendSearch() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection("groups/${widget.group.id}/members")
            .orderBy("username")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _buildListItem(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget buildSearch(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      title: new Text(
        document.data["username"],
        style: new TextStyle(color: UIData.blackOrWhite),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        if (widget.group.admin == true &&
            document.data["uid"] != widget.group.host) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePageAlt(
                      user: widget.user,
                      profileUserName: document.data["username"],
                      profileUserId: document.data["uid"],
                      profileUserIsAdmin: document.data["admin"],
                      group: widget.group,
                    )),
          );
        } else {}
      },
    );
  }

  Widget groupSearch() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection("groups/${widget.group.id}/members")
            .where("username", isEqualTo: groupSearchName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return loading();
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                buildSearch(context, snapshot.data.documents[index]),
          );
        });
  }
}
