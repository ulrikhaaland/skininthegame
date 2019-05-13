import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yadda/widgets/login_background.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/pages/group/group_pages/cashgame/group_page_cash_page.dart';
import 'package:yadda/pages/group/group_pages/tournament/tournamentPages/group_page_tournaments_page.dart';
import 'package:yadda/auth.dart';
import 'package:yadda/pages/group/group_pages/group_page_settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/pages/group/new/new.dart';
import '../group/group_pages/members/members_page.dart';
import '../group/group_pages/feed/feed_page.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/essentials.dart';
// import 'package:yadda/pages/inAppPurchase/subLevel.dart';
// import 'package:yadda/pages/inAppPurchase/subscription.dart';

class GroupDashboard extends StatefulWidget {
  const GroupDashboard(
      {Key key,
      this.auth,
      this.user,
      this.onSignOut,
      this.groupId,
      this.groupType,
      this.onUpdate,
      this.groupName,
      this.group,
      this.navHelperTextList,
      this.updateState})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final VoidCallback updateState;
  final String groupId;
  final String groupType;
  final String groupName;
  final VoidCallback onUpdate;
  final User user;
  final Group group;
  final List<String> navHelperTextList;

  @override
  GroupDashboardState createState() => GroupDashboardState();
}

class GroupDashboardState extends State<GroupDashboard> {
  static final formKey = new GlobalKey<FormState>();

  final BaseAuth auth = Auth();
  final Firestore fireStoreInstance = Firestore.instance;

  bool userFound = false;
  bool groupFound = false;
  bool newGroupOption = false;
  bool admin = false;
  bool isMember;
  bool thumbs;
  bool publicGroup;
  bool isLoading = false;

  int numberOfMembers;

  String currentUserId;
  String currentUserName;
  String groupId;
  String groupType;
  String host;

  Group group;

  String name;
  String dailyMessage;
  String members;
  String reputation;

  String type;
  Size deviceSize;
  Color thumbColor;
  IconData thumbIcon;

  @override
  initState() {
    super.initState();
    currentUserId = widget.user.id;
    currentUserName = widget.user.userName;
    groupId = widget.groupId;
    type = widget.groupType;

    _numberOfMembers();
    checkIfMemberAndGetUserInfo();
    getThumbs();
    // getGroup();
    widget.navHelperTextList.add("Group");
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: UIData.dark,
      body: new Form(
        key: formKey,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            LoginBackground(
              showIcon: false,
            ),
            setScreen(),
            Essentials().loading(isLoading),
          ],
        ),
      ),
    );
  }

  Widget appBarColumn(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 18.0),
          child: new Column(
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new IconButton(
                      icon: new Icon(
                        defaultTargetPlatform == TargetPlatform.android
                            ? Icons.arrow_back
                            : Icons.arrow_back_ios,
                        color: UIData.blackOrWhite,
                      ),
                      onPressed: () {
                        Navigator.canPop(context)
                            ? Navigator.pop(context)
                            : widget.onUpdate();
                      }),
                  Text(
                    group.getName(),
                    style: TextStyle(
                        fontSize: UIData.fontSize24,
                        fontWeight: FontWeight.w500,
                        color: UIData.blackOrWhite),
                    overflow: TextOverflow.ellipsis,
                  ),
                  userButton(),
                ],
              ),
            ],
          ),
        ),
      );

  // Check how many players is in this group.
  _numberOfMembers() async {
    CollectionReference cRef1 =
        fireStoreInstance.collection("groups/$groupId/members");
    DocumentReference docRef1 = fireStoreInstance.document("groups/$groupId");
    QuerySnapshot qSnap1 = await cRef1.getDocuments();
    if (qSnap1.documents.isEmpty) {
      numberOfMembers = 0;
      if (group != null) {}
      docRef1.updateData({
        "members": numberOfMembers,
      });
    } else {
      numberOfMembers = qSnap1.documents.length;
      docRef1.updateData({
        "members": numberOfMembers,
      });
    }
  }

  checkIfMemberAndGetUserInfo() {
    fireStoreInstance
        .document("groups/$groupId/members/$currentUserId")
        .get()
        .then((datasnapshot) {
      if (datasnapshot.exists) {
        isMember = true;
        thumbs = datasnapshot.data["thumbs"];
        admin = datasnapshot.data["admin"];
      } else {
        isMember = false;
      }
      getGroup();
    });
  }

  void addMemberToGroup() {
    fireStoreInstance
        .document("groups/$groupId/members/$currentUserId")
        .setData({
      "uid": widget.user.id,
      "username": widget.user.userName,
      "admin": false,
      "notification": true,
      "fcm": widget.user.fcm,
      "profilepicurl": widget.user.profilePicURL,
    });
    fireStoreInstance.document("users/$currentUserId/groups/$groupId").setData({
      "id": group.id,
      "name": group.name,
      "numberofcashgames": 0,
      "numberoftournaments": 0,
      "members": numberOfMembers + 1,
    });
    fireStoreInstance
        .document("users/$currentUserId/grouprequests/$groupId")
        .delete();
    isMember = true;
    widget.updateState();
    setState(() {});
  }

// Different button for group admins
  Widget userButton() {
    if (admin == true) {
      return new IconButton(
          icon: new Icon(
            Icons.settings,
            color: UIData.blackOrWhite,
            size: UIData.iconSizeAppBar,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => New(
                        group: group,
                        newGroupOption: newGroupOption,
                        admin: admin,
                        initState: () => getGroup(),
                        user: widget.user,
                      )),
            );
          });
    } else if (isMember == false) {
      return new GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: new Text(
              "Join",
              style: new TextStyle(
                  fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () async {
            // if (await SubLevel()
            //     .groupsLeft(widget.user.id, widget.user.subLevel)) {
            setState(() {
              isLoading = true;
            });

            addMemberToGroup();
            QuerySnapshot qSnap = await fireStoreInstance
                .collection("users/${widget.user.id}/grouprequests")
                .getDocuments();
            widget.user.notifications = qSnap.documents.length;
            Scaffold.of(formKey.currentState.context).showSnackBar(new SnackBar(
              backgroundColor: UIData.yellow,
              content: new Text(
                "You have joined group ${group.name}",
                textAlign: TextAlign.center,
                style: new TextStyle(color: UIData.whiteOrBlack),
              ),
            ));

            setState(() {
              isLoading = false;
            });
            // } else {
            //   int i;
            //   widget.user.subLevel == 0 ? i = 3 : i = 10;
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => Subscription(
            //                 user: widget.user,
            //                 info: true,
            //                 title:
            //                     "Your current subscription does only allow you to be a part of $i groups at any given time",
            //               )));
            // }
          });
    } else if (isMember == true) {
      return new IconButton(
        icon: new Icon(
          Icons.settings,
          color: UIData.blackOrWhite,
          size: UIData.iconSizeAppBar,
        ),
        onPressed: () {
          if (!widget.navHelperTextList.contains("Group")) {
            widget.navHelperTextList.add("Group");
          }
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupSettingsPage(
                      user: widget.user,
                      group: group,
                      publicGroup: publicGroup,
                      navHelperTextList: widget.navHelperTextList,
                    )),
          );
        },
      );
    }
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.all(5.0),
      child: child,
    );
  }

  Widget dailyMessageCard() {
    String message;
    isMember ? message = group.getDailyMessage() : message = group.getInfo();
    if (message.isNotEmpty)
      return new Padding(
          padding: EdgeInsets.all(12.0),
          child: new Align(
            alignment: Alignment.topCenter,
            child: new Container(
              decoration: new BoxDecoration(
                  color: UIData.listColor,
                  border: Border.all(color: Colors.grey[600]),
                  borderRadius:
                      new BorderRadius.all(const Radius.circular(8.0))),
              child: new Padding(
                  padding: EdgeInsets.all(12.0),
                  child: new Text(
                    message,
                    style: new TextStyle(
                        fontSize: 20.0, color: UIData.blackOrWhite),
                  )),
            ),
          ));
    else
      return new Container();
  }

  Widget actionMenuCard() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          color: UIData.cardColor,
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              mainAxisSpacing: 5,
              physics: ScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: 4,
              crossAxisCount: 2,
              children: <Widget>[
                new IconButton(
                  icon: new Icon(
                    Icons.whatshot,
                    color: Colors.red,
                    size: 50.0,
                  ),
                  onPressed: () {
                    if (isMember == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupTournaments(
                                  user: widget.user,
                                  group: group,
                                  groupType: type,
                                )),
                      );
                    }
                  },
                ),
                new IconButton(
                  icon: new Icon(
                    Icons.attach_money,
                    color: Colors.green,
                    size: 50.0,
                  ),
                  onPressed: () {
                    if (isMember == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupCashGames(
                                  group: group,
                                  user: widget.user,
                                )),
                      );
                    }
                  },
                ),
                GestureDetector(
                  child: new Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: new Text(
                      "Tournaments",
                      style: new TextStyle(
                          color: UIData.blackOrWhite,
                          fontSize: UIData.fontSize16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    if (isMember == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupTournaments(
                                  user: widget.user,
                                  group: group,
                                  groupType: type,
                                )),
                      );
                    }
                  },
                ),
                new GestureDetector(
                  child: new Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: new Text(
                      "Cash Games",
                      style: new TextStyle(
                        color: UIData.blackOrWhite,
                        fontSize: UIData.fontSize16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    if (isMember == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupCashGames(
                                  user: widget.user,
                                  group: group,
                                )),
                      );
                    }
                  },
                ),
                new IconButton(
                    icon: new Icon(
                      Icons.people,
                      color: Colors.blue,
                      size: 50.0,
                    ),
                    onPressed: () {
                      if (isMember == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MembersPage(
                                    user: widget.user,
                                    group: group,
                                    groupType: type,
                                  )),
                        );
                      }
                    }),
                new IconButton(
                  icon: new Icon(
                    Icons.message,
                    color: UIData.yellow,
                    size: 50.0,
                  ),
                  onPressed: () {
                    if (isMember == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FeedPage(user: widget.user, group: group)),
                      );
                    }
                  },
                ),
                new GestureDetector(
                    child: new Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: new Text(
                        "Members",
                        style: new TextStyle(
                            color: UIData.blackOrWhite,
                            fontSize: UIData.fontSize16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onTap: () {
                      if (isMember == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MembersPage(
                                    user: widget.user,
                                    group: group,
                                    groupType: type,
                                  )),
                        );
                      }
                    }),
                new GestureDetector(
                  child: new Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: new Text(
                      "Posts",
                      style: new TextStyle(
                          color: UIData.blackOrWhite,
                          fontSize: UIData.fontSize16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    if (isMember == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FeedPage(user: widget.user, group: group)),
                      );
                    }
                  },
                ),
                // Padding(
                //   padding: EdgeInsets.only(top: 0),
                // )
              ],
            ),
          ),
        ),
      );

  Widget balanceCard() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          color: UIData.cardColor,
          elevation: 2.0,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Stack(
                children: <Widget>[
                  GridView.count(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      childAspectRatio: 7,
                      crossAxisCount: 2,
                      children: <Widget>[
                        Text(
                          "Members",
                          style: TextStyle(
                              fontFamily: UIData.ralewayFont,
                              color: UIData.blackOrWhite,
                              fontSize: UIData.fontSize16),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${group.rating.toStringAsFixed(1)}",
                          style: TextStyle(
                              fontFamily: UIData.ralewayFont,
                              color: UIData.blackOrWhite,
                              fontSize: UIData.fontSize16),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${group.getMembers()}",
                          style: TextStyle(
                              fontFamily: UIData.ralewayFont,
                              fontWeight: FontWeight.w700,
                              color: UIData.green,
                              fontSize: 25.0),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        new GestureDetector(
                          child: new Icon(
                            Icons.star,
                            size: 30.0,
                            color: Color.lerp(Colors.grey[600], UIData.yellow,
                                group.rating / 5),
                          ),
                          onTap: () async {
                            if (admin != true && isMember == true) {
                              DocumentSnapshot docsnap = await fireStoreInstance
                                  .document(
                                      "groups/${group.id}/rating/${widget.user.id}")
                                  .get();
                              if (docsnap.exists) {
                                showRateGroupAlert(docsnap.data["rating"] + .0);
                              } else {
                                showRateGroupAlert(0);
                              }
                            }
                          },
                        ),
                        new Container()
                        // onPressed: () async {
                        //   if (admin != true && isMember == true) {
                        //     DocumentSnapshot docsnap = await fireStoreInstance
                        //         .document(
                        //             "groups/${group.id}/rating/${widget.user.id}")
                        //         .get();
                        //     if (docsnap.exists) {
                        //       showRateGroupAlert(docsnap.data["rating"] + .0);
                        //     } else {
                        //       showRateGroupAlert(0);
                        //     }
                        //   }
                        // },
                      ]),
                  // new Positioned(
                  //   right: 69,
                  //   top: 37,
                  //   child:
                  // ),
                ],
              )

              // Column(
              //   children: <Widget>[
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceAround,
              //       children: <Widget>[
              //         new Column(children: <Widget>[
              //           Text(
              //             "Members",
              //             style: TextStyle(
              //                 fontFamily: UIData.ralewayFont,
              //                 color: UIData.blackOrWhite,
              //                 fontSize: UIData.fontSize16),
              //           ),
              //           padded(),
              //           Text(
              //             "${group.getMembers()}",
              //             style: TextStyle(
              //                 fontFamily: UIData.ralewayFont,
              //                 fontWeight: FontWeight.w700,
              //                 color: UIData.green,
              //                 fontSize: 25.0),
              //             overflow: TextOverflow.ellipsis,
              //           ),
              //         ]),
              //         new Column(children: <Widget>[
              //           padded(),
              //           Text(
              //             "${group.rating.toStringAsFixed(1)}",
              //             style: TextStyle(
              //                 fontFamily: UIData.ralewayFont,
              //                 color: UIData.blackOrWhite,
              //                 fontSize: UIData.fontSize16),
              //             overflow: TextOverflow.ellipsis,
              //           ),
              //           new IconButton(
              //             icon: new Icon(
              //               Icons.star,
              //               size: 30.0,
              //               color: Color.lerp(Colors.grey[600], UIData.yellow,
              //                   group.rating / 5),
              //             ),
              //             onPressed: () async {
              //               if (admin != true && isMember == true) {
              //                 DocumentSnapshot docsnap = await fireStoreInstance
              //                     .document(
              //                         "groups/${group.id}/rating/${widget.user.id}")
              //                     .get();
              //                 if (docsnap.exists) {
              //                   showRateGroupAlert(docsnap.data["rating"] + .0);
              //                 } else {
              //                   showRateGroupAlert(0);
              //                 }
              //               }
              //             },
              //           ),
              //         ]),
              //       ],
              //     ),
              //   ],
              // ),
              ),
        ),
      );

  void setRatingAnimation(double howMany, bool isDone) async {
    Navigator.pop(context);
    showRateGroupAlert(howMany);
    if (isDone == true) {
      await fireStoreInstance
          .document("groups/${group.id}/rating/${widget.user.id}")
          .setData({"rating": howMany});
      getThumbs();
      Navigator.pop(context);
    }
  }

  void showRateGroupAlert(double howMany) {
    Color btn1 = Colors.grey[600];
    Color btn2 = Colors.grey[600];
    Color btn3 = Colors.grey[600];
    Color btn4 = Colors.grey[600];
    Color btn5 = Colors.grey[600];

    if (howMany >= 1) {
      btn1 = Colors.yellow[700];
    }
    if (howMany >= 2) {
      btn2 = Colors.yellow[700];
    }
    if (howMany >= 3) {
      btn3 = Colors.yellow[700];
    }
    if (howMany >= 4) {
      btn4 = Colors.yellow[700];
    }
    if (howMany >= 5) {
      btn5 = Colors.yellow[700];
    }
    AlertDialog dialog = new AlertDialog(
      title: new Text(
        "Rate Group",
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.all(20.0),
      actions: <Widget>[
        new IconButton(
          icon: Icon(
            Icons.star,
            color: btn1,
          ),
          onPressed: () => setRatingAnimation(1, true),
        ),
        new IconButton(
          icon: Icon(Icons.star, color: btn2),
          onPressed: () => setRatingAnimation(2, true),
        ),
        new IconButton(
          icon: Icon(Icons.star, color: btn3),
          onPressed: () => setRatingAnimation(3, true),
        ),
        new IconButton(
          icon: Icon(Icons.star, color: btn4),
          onPressed: () => setRatingAnimation(4, true),
        ),
        new IconButton(
          icon: Icon(Icons.star, color: btn5),
          onPressed: () => setRatingAnimation(5, true),
        ),
      ],
    );
    showDialog(context: context, child: dialog);
  }

  awaitThumbsUp() {
    fireStoreInstance
        .document("groups/$groupId/thumbs/$currentUserId")
        .get()
        .then((datasnapshot) {
      if (!datasnapshot.exists) {
        // showRateGroupAlert();
        // fireStoreInstance
        //     .document("groups/$groupId/thumbs/$currentUserId")
        //     .setData({});
        // thumbs = true;
        // setState(() {
        //   thumbColor = UIData.red;
        //   thumbIcon = Icons.thumb_down;
        // });
        // getThumbs();
      }
    });
  }

  void getThumbs() {
    double rating = 0.0;
    CollectionReference cRef =
        fireStoreInstance.collection("groups/$groupId/rating");
    fireStoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot qSnap = await cRef.getDocuments();
      if (qSnap.documents.isEmpty) {
        rating = 0;
        if (group != null) {
          group.setRating(0);
        }
      } else {
        qSnap.documents.forEach((DocumentSnapshot snap) {
          rating += snap.data["rating"];
        });
        setState(() {
          rating = rating / qSnap.documents.length;
          if (group != null) {
            group.setRating(rating);
          }
        });
      }
      fireStoreInstance.runTransaction((Transaction tx) async {
        await fireStoreInstance.document("groups/$groupId").updateData({
          'rating': rating,
        });
      });
    });
  }

  Widget allCards(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: <Widget>[
            appBarColumn(context),
            dailyMessageCard(),
            SizedBox(
              height: deviceSize.height * 0.07,
            ),
            actionMenuCard(),
            SizedBox(
              height: deviceSize.height * 0.01,
            ),
            balanceCard(),
          ],
        ),
      );

  getGroup() async {
    if (widget.group == null) {
      await fireStoreInstance.runTransaction((Transaction tx) async {
        DocumentSnapshot documentSnapshot =
            await fireStoreInstance.document("groups/$groupId").get();
        if (documentSnapshot.exists) {
          group = new Group(
            documentSnapshot.data["name"],
            documentSnapshot.data["dailymessage"],
            documentSnapshot.data["host"],
            documentSnapshot.data["id"],
            documentSnapshot.data["info"],
            documentSnapshot.data["lowercasename"],
            documentSnapshot.data["members"],
            documentSnapshot.data["public"],
            documentSnapshot.data["rating"] + .0,
            admin,
            documentSnapshot.data["numberofcashgames"],
            documentSnapshot.data["numberoftournaments"],
            documentSnapshot.data["shareresults"],
          );
          if (widget.user.id == group.host) {
            admin = true;
            group.admin = true;
          }
          groupFound = true;

          try {
            widget.onUpdate();
          } catch (e) {
            print(e);
          }
          setState(() {});
        } else {
          print("failed");
        }
      });
    } else {
      group = widget.group;
      groupFound = true;
      widget.onUpdate();
      setState(() {});
    }
  }

  String getGroupId() {
    return groupId;
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  setScreen() {
    if (isMember != null) {
      if (groupFound == false) {
        return loading();
      } else {
        return allCards(context);
      }
    } else {
      return loading();
    }
  }
}
