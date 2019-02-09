import 'package:flutter/material.dart';
import 'package:yadda/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/userSearch/search.dart';
import 'package:yadda/objects/group.dart';

import 'package:yadda/utils/time.dart';

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

class InviteUserPage extends StatefulWidget {
  const InviteUserPage({Key key, this.user, this.group}) : super(key: key);
  final User user;
  final Group group;

  @override
  InviteUserPageState createState() => InviteUserPageState();
}

class InviteUserPageState extends State<InviteUserPage> {
  final bool newGroupOption = true;
  final Firestore fireStoreInstance = Firestore.instance;
  final BaseAuth auth = Auth();

  bool userFound = false;
  bool registeredGames = true;
  bool getStatus = false;
  bool noGroups = false;

  int numberOfCashGames = 0;
  int numberOfTournaments = 0;
  int screen = 0;
  int members = 0;

  String currentUserId;
  String type;
  String userSearchName;

  List<String> data = new List<String>();
  String currentUserName;
  String email;
  String uid;
  String onTapGroupId;

  initState() {
    super.initState();
    currentUserId = widget.user.userName;
    userIdFound();
  }

  InviteUserPageState() {
    searchBar = new SearchBar(
      showClearButton: true,
      onSubmitted: onSubmitted,
      inBar: true,
      buildDefaultAppBar: _buildAppBar,
      setState: setState,
    );
  }

  void onSubmitted(String value) {
    setState(() {
      userSearchName = value;
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
          elevation: 0,
          title: new Directionality(
            textDirection: Directionality.of(context),
            child: TextField(
              autofocus: true,
              autocorrect: false,
              style: new TextStyle(color: UIData.blackOrWhite),
              decoration: InputDecoration(
                fillColor: UIData.white,
                labelText: 'Search for users',
                labelStyle: new TextStyle(color: Colors.grey[600]),
                icon: new Icon(Icons.supervised_user_circle,
                    size: 40.0, color: UIData.blue),
              ),
              onChanged: (String value) {
                userSearchName = value.toLowerCase();
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

  returnGroupId() {
    return onTapGroupId;
  }

  getGroupId() {
    noGroups = false;
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  Widget introduction() {
    return new Padding(
        padding: EdgeInsets.all(10.0),
        child: new Align(
          alignment: Alignment.topCenter,
          child: new Container(
            decoration: new BoxDecoration(
                color: UIData.listColor,
                border: Border.all(color: Colors.grey[600]),
                borderRadius: new BorderRadius.all(const Radius.circular(8.0))),
            child: new Padding(
                padding: EdgeInsets.all(10.0),
                child: new Text(
                  "Invite users to join the group!",
                  style: new TextStyle(
                    fontSize: 25.0,
                    color: UIData.blackOrWhite,
                  ),
                )),
          ),
        ));
  }

  setScreen() {
    if (userFound == false && screen == 0) {
      return loading();
    } else if (screen == 1) {
      return groupSearch();
    } else if (screen == 0) {
      return introduction();
    }
  }

  userIdFound() {
    userFound = true;
    print(userFound);
    setState(() {
      setScreen();
    });
  }

  Widget buildSearch(BuildContext context, DocumentSnapshot document) {
    if (document.documentID != widget.user.id) {
      return ListTile(
          contentPadding: EdgeInsets.all(3.0),
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: new BoxDecoration(
                    border: Border.all(color: Colors.grey[600]),
                    borderRadius:
                        new BorderRadius.all(const Radius.circular(8.0))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(document['name'],
                        overflow: TextOverflow.ellipsis,
                        style: new TextStyle(color: UIData.blackOrWhite)),
                    new Padding(
                      padding: EdgeInsets.all(1.0),
                    ),
                    new Row(children: <Widget>[
                      // new Text(document['members']),
                      new Icon(
                        Icons.person_add,
                        color: Colors.blue,
                      ),
                    ]),
                  ],
                ),
              )),
            ],
          ),
          onTap: () {
            addUserToGroup(document["id"]);
            Scaffold.of(context).showSnackBar(new SnackBar(
              backgroundColor: UIData.yellow,
              content: new Text(
                'An invite to join this group has been sent to "${document["name"]}"',
                textAlign: TextAlign.center,
                style: new TextStyle(color: Colors.black),
              ),
            ));
          });
    } else {
      return Container();
    }
  }

  void addUserToGroup(String addedUserId) {
    Time time = new Time();
    int finalDateAndTime = time.getOrderByTime();
    fireStoreInstance
        .document("users/$addedUserId/grouprequests/${widget.group.id}")
        .setData({
      "groupid": widget.group.id,
      "groupname": widget.group.name,
      "sendername": widget.user.userName,
      "finaldateaandtime": finalDateAndTime,
      "fromadmin": widget.group.admin,
    });
  }

  Widget groupSearch() {
    return StreamBuilder(
        stream: fireStoreInstance
            .collection("users")
            .where("name", isEqualTo: userSearchName)
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
