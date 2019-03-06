import 'package:flutter/material.dart';
import 'package:yadda/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/pages/userSearch/search.dart';
import 'package:yadda/pages/group/group_page_one.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/group/new/newGroup.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yadda/pages/results/graph.dart';
import 'package:yadda/pages/profile/invite_page.dart';
import 'package:yadda/pages/profile/profile_page.dart';
import 'package:yadda/pages/inAppPurchase/subscription.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yadda/utils/delete.dart';
import 'package:yadda/pages/inAppPurchase/sublevel.dart';

SearchBar searchBar;

AppBar _buildAppBar(BuildContext context) {
  return new AppBar(
    // title: new Text("Søk etter medlemmer"),
    actions: <Widget>[
      searchBar.getSearchAction(context),
    ],
  );
}

class GamePage extends StatefulWidget {
  const GamePage(
      {Key key,
      this.auth,
      this.user,
      this.onSignOut,
      this.changeColor,
      this.setProfilePage})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback changeColor;
  final VoidCallback onSignOut;
  final VoidCallback setProfilePage;
  final User user;
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  // static final formKey = new GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  final bool newGroupOption = true;
  final Firestore firestoreInstance = Firestore.instance;
  final BaseAuth auth = Auth();

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

  IconData nightmodeIcon;

  GamePageState() {
    searchBar = new SearchBar(
      showClearButton: true,
      inBar: true,
      buildDefaultAppBar: _buildAppBar,
      setState: setState,
    );
  }

  @override
  initState() {
    super.initState();
    checkSubLevel();
    currentUserId = widget.user.id;
    _registeredGames();
    if (widget.user.nightMode) {
      nightmodeIcon = FontAwesomeIcons.solidMoon;
    } else {
      nightmodeIcon = FontAwesomeIcons.moon;
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  checkSubLevel() {
    SubLevel().getSubLevel().then((onValue) =>
        widget.user != null ? widget.user.subLevel = onValue : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        drawer: Drawer(
          child: Container(
            color: UIData.dark,
            child: ListView(
              children: <Widget>[
                new ListTile(
                  contentPadding: EdgeInsets.only(left: 28, top: 16),
                  leading: addImage(),
                ),
                new ListTile(
                  contentPadding: EdgeInsets.only(left: 32),
                  title: new Text(
                    widget.user.userName,
                    style: new TextStyle(
                        color: UIData.blackOrWhite,
                        fontSize: UIData.fontSize20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  subtitle: new Text(
                    widget.user.email,
                    style: new TextStyle(
                        color: Colors.grey[600],
                        fontSize: UIData.fontSize16,
                        letterSpacing: 1),
                  ),
                ),
                new ListTile(),
                new ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.person, size: 30, color: Colors.grey),
                    onPressed: null,
                  ),
                  title: new Text(
                    "Profile",
                    style: new TextStyle(
                      fontSize: UIData.fontSize18,
                      color: UIData.blackOrWhite,
                    ),
                  ),
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfilePage(
                                  user: widget.user,
                                  profileId: widget.user.id,
                                )),
                      ),
                ),
                new ListTile(
                  leading: IconButton(
                    icon: Icon(FontAwesomeIcons.award, color: Colors.grey),
                    onPressed: null,
                  ),
                  title: new Text(
                    "Results",
                    style: new TextStyle(
                      fontSize: UIData.fontSize18,
                      color: UIData.blackOrWhite,
                    ),
                  ),
                  onTap: () {
                    if (widget.user.subLevel > 0) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ResultPage(
                                    user: widget.user,
                                    currentUser: widget.user,
                                    isLoading: true,
                                  )));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Subscription(
                                    user: widget.user,
                                    title: "Subscription",
                                  )));
                    }
                  },
                ),
                new ListTile(
                  leading: IconButton(
                    icon:
                        Icon(Icons.mail_outline, size: 30, color: Colors.grey),
                    onPressed: null,
                  ),
                  title: new Row(
                    children: <Widget>[
                      new Text(
                        "Invites ",
                        style: new TextStyle(
                          fontSize: UIData.fontSize18,
                          color: UIData.blackOrWhite,
                        ),
                      ),
                      notificationAmount(),
                    ],
                  ),
                  onTap: () =>
                      // widget.onSignOut(),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserPageInvites(
                                  user: widget.user,
                                  updateState: () => updateState(),
                                )),
                      ),
                ),
                new ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.exit_to_app, size: 30, color: Colors.grey),
                    onPressed: null,
                  ),
                  title: new Text(
                    "Logout",
                    style: new TextStyle(
                      fontSize: UIData.fontSize18,
                      color: UIData.blackOrWhite,
                    ),
                  ),
                  onTap: () => widget.onSignOut(),
                ),
                new ListTile(
                  leading: IconButton(
                    icon: Icon(nightmodeIcon, size: 20, color: UIData.yellow),
                    onPressed: null,
                  ),
                  onTap: () {
                    UIData().nightMode(!widget.user.nightMode, widget.user.id);
                    widget.user.nightMode = !widget.user.nightMode;
                    widget.changeColor();
                    if (widget.user.nightMode) {
                      nightmodeIcon = FontAwesomeIcons.solidMoon;
                    } else {
                      nightmodeIcon = FontAwesomeIcons.moon;
                    }
                    setState(() {});
                  },
                ),

                // new ListTile(
                //   leading: IconButton(
                //     icon: Icon(Icons.exit_to_app, size: 30, color: Colors.grey),
                //     onPressed: null,
                //   ),
                //   title: new Text(
                //     "Logout",
                //     style: new TextStyle(
                //       fontSize: UIData.fontSize18,
                //       color: UIData.blackOrWhite,
                //     ),
                //   ),
                //   onTap: () => Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => Subscription(
                //                   user: widget.user,
                //                   title: "Subscriptions",
                //                 )),
                //       ),
                // ),
              ],
            ),
          ),
        ),
        resizeToAvoidBottomPadding: true,
        backgroundColor: UIData.dark,
        appBar: new AppBar(
          // elevation: 0,
          backgroundColor: UIData.appBarColor,
          actions: <Widget>[
            IconButton(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                icon: new Icon(
                  Icons.add_circle_outline,
                  color: UIData.blackOrWhite,
                  size: UIData.iconSizeAppBar,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewGroup(
                              user: widget.user,
                              onUpdate: () => _registeredGames(),
                            )),
                  );
                }),
          ],
          leading: new IconButton(
            iconSize: UIData.iconSizeAppBar,
            icon: new Stack(children: <Widget>[
              Icon(
                Icons.person,
                color: Colors.grey[600],
              ),
              new Positioned(
                // draw a red marble
                top: 0.0,
                right: 0.0,
                child: notificationAmount(),
              )
            ]),
            onPressed: () => _key.currentState.openDrawer(),
          ),
          centerTitle: true,
          title: new Directionality(
            textDirection: Directionality.of(context),
            child: TextField(
              autocorrect: false,
              style: new TextStyle(color: UIData.blackOrWhite),
              decoration: InputDecoration(
                fillColor: UIData.blackOrWhite,
                labelText: 'Tap to search for group',
                labelStyle: new TextStyle(color: Colors.grey[700]),
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
                    _registeredGames();
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
          // backgroundColor: UIData.darkest,
        ),
        body: setScreen());
  }

  void updateState() {
    setState(() {
      noGroups = false;
    });
  }

  Widget addImage() {
    if (widget.user.image != null) {
      return new CircleAvatar(
        radius: 35,
        backgroundImage: FileImage(widget.user.image),
        backgroundColor: Colors.grey[600],
      );
    } else if (widget.user.profilePicURL == null) {
      return new CircleAvatar(
        radius: 35,
        child: Icon(
          Icons.person_outline,
          color: Colors.white,
          size: 40,
        ),
        backgroundColor: Colors.grey[600],
      );
    } else {
      return new CircleAvatar(
        radius: 35,
        backgroundColor: Colors.grey[600],
        backgroundImage: CachedNetworkImageProvider(widget.user.profilePicURL),
      );
    }
  }

  Widget notificationAmount() {
    if (widget.user.notifications > 0) {
      return new CircleAvatar(
        backgroundColor: UIData.red,
        maxRadius: 10,
        child: Text(
          "${widget.user.notifications}",
        ),
      );
    } else {
      return new Container();
    }
  }

  // Check how many games is registered in each group.
  _registeredGames() {
    CollectionReference cRef1 =
        firestoreInstance.collection("users/$currentUserId/groups");
    Firestore.instance.runTransaction((Transaction tx) async {
      List<String> groups = new List<String>();

      QuerySnapshot qSnap1 = await cRef1.getDocuments();
      if (qSnap1.documents.isNotEmpty) {
        for (int i = 0; i < qSnap1.documents.length; i++) {
          String data = qSnap1.documents[i].data["id"];
          groups.add(data);

          firestoreInstance.runTransaction((Transaction tx) async {
            CollectionReference cRef2 = firestoreInstance
                .collection("groups/${groups[i]}/games/type/tournamentactive");
            QuerySnapshot qSnap2 = await cRef2.getDocuments();
            if (qSnap2.documents.isEmpty) {
              numberOfTournaments = 0;
            } else {
              numberOfTournaments = qSnap2.documents.length;
            }
            print(numberOfTournaments);
            firestoreInstance
                .document("users/$currentUserId/groups/${groups[i]}")
                .updateData({
              "numberoftournaments": numberOfTournaments,
            });
          });
          firestoreInstance.runTransaction((Transaction tx) async {
            CollectionReference cRef3 = firestoreInstance
                .collection("groups/${groups[i]}/games/type/cashgameactive");
            QuerySnapshot qSnap3 = await cRef3.getDocuments();
            if (qSnap3.documents.isEmpty) {
              numberOfCashGames = 0;
              firestoreInstance
                  .document("users/$currentUserId/groups/${groups[i]}")
                  .updateData({
                "numberofcashgames": numberOfCashGames,
              });
            } else {
              numberOfCashGames = qSnap3.documents.length;
              firestoreInstance
                  .document("users/$currentUserId/groups/${groups[i]}")
                  .updateData({
                "numberofcashgames": numberOfCashGames,
              });
            }
          });
          firestoreInstance.runTransaction((Transaction tx) async {
            DocumentReference dRef1 =
                firestoreInstance.document("groups/${groups[i]}");
            DocumentSnapshot dSnap1 = await dRef1.get();
            if (dSnap1.exists) {
              members = dSnap1.data["members"];
              firestoreInstance
                  .document("users/$currentUserId/groups/${groups[i]}")
                  .updateData({
                "members": members,
              });
            } else {
              members = 0;
              firestoreInstance
                  .document("users/$currentUserId/groups/${groups[i]}")
                  .updateData({
                "members": members,
              });
            }
          });
        }
        userFound = true;
        setScreen();
        setState(() {});
      } else {
        noGroups = true;
        userFound = true;
        setScreen();
        setState(() {});
      }
    });
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
                  "Search for groups or create one by tapping the + icon ",
                  style:
                      new TextStyle(fontSize: 25.0, color: UIData.blackOrWhite),
                )),
          ),
        ));
  }

  setScreen() {
    if (userFound == false && screen == 0) {
      return loading();
    } else if (userFound == true && screen == 0 && noGroups == false) {
      return friendSearch();
    } else if (screen == 1) {
      return groupSearch();
    } else if (noGroups == true) {
      return introduction();
    }
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    String deleteOrLeave = "Leave";
    widget.user.id == document.data["host"] ? deleteOrLeave = "Delete" : null;
    return new Slidable(
      // enabled: enabled,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: .25,
      child: new Container(
        child: new ListTile(
          contentPadding: EdgeInsets.all(3.0),
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: Container(
                // color: Colors.grey,
                padding: EdgeInsets.all(10.0),
                decoration: new BoxDecoration(
                    color: UIData.listColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius:
                        new BorderRadius.all(const Radius.circular(8.0))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      document['name'],
                      style: new TextStyle(
                          color: UIData.blackOrWhite,
                          fontSize: UIData.fontSize20),
                      overflow: TextOverflow.ellipsis,
                    ),
                    new Padding(
                      padding: EdgeInsets.all(1.0),
                    ),
                    new Row(children: <Widget>[
                      new Icon(
                        Icons.whatshot,
                        color: Colors.red,
                        size: 25.0,
                      ),
                      Text(" ${document["numberoftournaments"].toString()}",
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                              color: UIData.blackOrWhite,
                              fontSize: UIData.fontSize20)),
                      new Icon(
                        Icons.attach_money,
                        color: Colors.green,
                        size: 25.0,
                      ),
                      Text("${document["numberofcashgames"].toString()}",
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                              color: UIData.blackOrWhite,
                              fontSize: UIData.fontSize20)),
                    ]),
                  ],
                ),
              )),
            ],
          ),
          onTap: () {
            groupId = document.documentID;

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GroupDashboard(
                        user: widget.user,
                        groupId: groupId,
                        updateState: () => updateState(),
                        // groupType: type,
                        onUpdate: () => _registeredGames(),
                      )),
            );
          },
        ),
      ),
      secondaryActions: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
          child: new IconSlideAction(
              caption: deleteOrLeave,
              color: UIData.red,
              icon: Icons.delete,
              onTap: () =>
                  _showDeleteGroupAlert(deleteOrLeave, document.data["id"])),
        ),
      ],
    );
  }

  Widget friendSearch() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection("users/$currentUserId/groups")
            .orderBy("members", descending: true)
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
    return ListTile(
      contentPadding: EdgeInsets.all(3.0),
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
              child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: new BoxDecoration(
                color: UIData.listColor,
                border: Border.all(color: Colors.grey),
                borderRadius: new BorderRadius.all(const Radius.circular(8.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(document['name'],
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(
                        color: UIData.blackOrWhite,
                        fontSize: UIData.fontSize20)),
                new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.people,
                      color: Colors.blue,
                      size: 25.0,
                    ),
                    new Padding(
                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0)),
                    Text("${document['members']}",
                        overflow: TextOverflow.ellipsis,
                        style: new TextStyle(
                            color: UIData.blackOrWhite,
                            fontSize: UIData.fontSize20)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
      onTap: () {
        groupId = document.documentID;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupDashboard(
                    user: widget.user,
                    groupId: groupId,
                    updateState: () => updateState(),

                    // groupType: type,
                    onUpdate: () => _registeredGames(),
                  )),
        );
      },
    );
  }

  Widget groupSearch() {
    return StreamBuilder(
        stream: firestoreInstance
            .collection("groups")
            .where("lowercasename", isEqualTo: groupSearchName.trim())
            .where("public", isEqualTo: true)
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

  void _showDeleteGroupAlert(String deleteOrLeave, String gid) {
    AlertDialog dialog = new AlertDialog(
      title: new Text(
        "Are you sure you want to ${deleteOrLeave.toLowerCase()} this group?",
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.all(20.0),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              userFound = false;
            });
            if (deleteOrLeave == "Leave") {
              await firestoreInstance
                  .document("users/${widget.user.id}/groups/$gid")
                  .delete();
              await firestoreInstance
                  .document("groups/$gid/members/${widget.user.id}")
                  .delete();
            } else if (deleteOrLeave == "Delete") {
              await Delete().deleteGroup(gid);
            }
            setState(() {
              userFound = true;
            });
          },
          child: new Text(
            "Yes",
            textAlign: TextAlign.left,
          ),
        ),
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text("Cancel"),
        ),
      ],
    );
    showDialog(context: context, child: dialog);
  }
}
