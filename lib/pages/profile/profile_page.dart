import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/profile/profile_page_settings.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/pages/profile/profile_page_results.dart';
import 'package:yadda/objects/resultgame.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yadda/pages/results/graph.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'package:yadda/pages/inAppPurchase/subscription.dart';
import 'package:yadda/widgets/report_dialog.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage(
      {Key key, this.user, this.setGroupPage, this.profileId, this.signOut})
      : super(key: key);
  final String profileId;
  final VoidCallback setGroupPage;
  final VoidCallback signOut;
  final User user;

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  TabController _tabController;
  final Firestore firestoreInstance = Firestore.instance;

  bool userFound = false;

  String followOrEdit = "Settings";

  bool ownProfile = false;

  User userProfile;

  double profileBGSize = 180;

  QuerySnapshot qSnapCash;
  QuerySnapshot qSnapTournament;

  String block = "Block";
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 4);

    if (widget.user.id == widget.profileId) {
      followOrEdit = "Settings";
      ownProfile = true;
    } else {
      followOrEdit = "Results";
    }
    getUserInfo();
    checkBlocked();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }

  checkBlocked() async {
    if (!ownProfile) {
      DocumentSnapshot docSnap = await firestoreInstance
          .document("users/${widget.user.id}/blocked/${widget.profileId}")
          .get();
      if (docSnap.exists) {
        block = "Unblock";
        isBlocked = true;
      }
    }
  }

  Future<QuerySnapshot> cashStream() async {
    qSnapCash = await Firestore.instance
        .collection("users/${userProfile.id}/cashgameresults")
        .orderBy("orderbytime", descending: true)
        .getDocuments();
    qSnapTournament = await Firestore.instance
        .collection("users/${userProfile.id}/tournamentresults")
        .orderBy("orderbytime", descending: true)
        .getDocuments();
    return qSnapCash;
  }

  void getUserInfo() async {
    if (ownProfile == true) {
      setState(() {
        userFound = true;
        userProfile = widget.user;
      });
    } else {
      await firestoreInstance.runTransaction((Transaction tx) async {
        DocumentSnapshot docSnap =
            await firestoreInstance.document("users/${widget.profileId}").get();
        userProfile = new User(
          docSnap.data["email"],
          docSnap.data["id"],
          docSnap.data["name"],
          docSnap.data["fcm"],
          docSnap.data["bio"],
          docSnap.data["nightmode"],
          docSnap.data["shareresults"],
          docSnap.data["following"],
          docSnap.data["followers"],
          null,
          docSnap.data["profilepicurl"],
          docSnap.data["currency"],
          null,
          docSnap.data["sublevel"],
        );
      });
    }
    await cashStream();
    setState(() {
      userFound = true;
    });
    setBGSize();
  }

  void setBGSize() {
    if (userProfile.bio.length <= 42) {
      profileBGSize = 180;
    } else if (userProfile.bio.length <= 87) {
      profileBGSize = 210;
    } else if (userProfile.bio.length <= 131) {
      profileBGSize = 230;
    } else {
      profileBGSize = 240;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userFound == true) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: UIData.appBarColor,
          iconTheme: IconThemeData(color: UIData.appBarColor),
          leading: new IconButton(
            icon: new Icon(
              defaultTargetPlatform == TargetPlatform.android
                  ? Icons.arrow_back
                  : Icons.arrow_back_ios,
              color: UIData.blackOrWhite,
            ),
            onPressed: () =>
                Navigator.canPop(context) ? Navigator.pop(context) : null,
          ),
          actions: <Widget>[
            settingsButton(),
            reportButton(),
          ],
          bottom: PreferredSize(
            preferredSize: Size(0, profileBGSize),
            child: new Column(
              children: <Widget>[
                new Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 14),
                      child: addImage(),
                    ),
                    resultsButton(),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 8),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      userProfile.userName,
                      style: TextStyle(
                          color: UIData.blackOrWhite,
                          fontSize: UIData.fontSize20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, left: 16.0),
                    child: Text(
                      userProfile.bio,
                      overflow: TextOverflow.clip,
                      style:
                          TextStyle(color: UIData.blackOrWhite, fontSize: 14),
                      maxLines: 4,
                    ),
                  ),
                ),
                // new Row(
                //   children: <Widget>[
                //     RaisedButton(
                //       elevation: 0,
                //       color: UIData.appBarColor,
                //       child: new Row(
                //         children: <Widget>[
                //           new Text(
                //             "Following",
                //             style: new TextStyle(color: Colors.grey[600]),
                //           ),
                //           new Text(
                //             " ${userProfile.following}",
                //             style: new TextStyle(color: UIData.blackOrWhite),
                //           ),
                //         ],
                //       ),
                //       onPressed: () => print(""),
                //     ),
                //     RaisedButton(
                //       elevation: 0,
                //       color: UIData.appBarColor,
                //       child: new Row(
                //         children: <Widget>[
                //           new Text(
                //             "Followers",
                //             style: new TextStyle(color: Colors.grey[600]),
                //           ),
                //           new Text(
                //             " ${userProfile.followers}",
                //             style: new TextStyle(color: UIData.blackOrWhite),
                //           ),
                //         ],
                //       ),
                //       onPressed: () => print(""),
                //     ),
                //   ],
                // ),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Text(
                        "Cash Games",
                        style: new TextStyle(color: UIData.blackOrWhite),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Tournaments",
                        style: new TextStyle(color: UIData.blackOrWhite),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        backgroundColor: UIData.dark,
        body: new Stack(
          children: <Widget>[
            new TabBarView(
              physics: ScrollPhysics(),
              controller: _tabController,
              children: [
                setCashStream(),
                setTournamentStream(),
              ],
            ),
          ],
        ),
      );
    } else {
      return Essentials();
    }
  }

  Widget settingsButton() {
    if (ownProfile) {
      return new Padding(
        padding: EdgeInsets.only(right: 4.0),
        child: new IconButton(
          icon: new Icon(
            Icons.settings,
            size: UIData.iconSizeAppBar,
            color: UIData.blackOrWhite,
          ),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileSettingsPage(
                        user: widget.user,
                        setBGSize: () => setBGSize(),
                        signOut: () => widget.signOut(),
                      ))),
        ),
      );
    } else {
      return new Container();
    }
  }

  Widget reportButton() {
    if (!ownProfile) {
      return new Padding(
        padding: EdgeInsets.only(right: 4.0),
        child: new IconButton(
            icon: new Icon(
              Icons.more_vert,
              size: UIData.iconSizeAppBar,
              color: UIData.blackOrWhite,
            ),
            onPressed: () {
              _showAlert();
            }),
      );
    } else {
      return new Container();
    }
  }

  void _showAlert() {
    AlertDialog dialog = new AlertDialog(
      backgroundColor: UIData.dark,
      content: new Container(
        height: 120,
        child: new Column(
          children: <Widget>[
            new ListTile(
              leading: new Icon(
                Icons.flag,
                color: UIData.yellow,
              ),
              title: new Text(
                "Report",
                style: TextStyle(color: UIData.blackOrWhite),
              ),
              onTap: () {
                Navigator.pop(context);
                ReportDialog reportDialog = new ReportDialog(
                  text: "Report user",
                  reportedById: widget.user.id,
                  type: "user",
                  reportedId: userProfile.id,
                );
                showDialog(context: context, child: reportDialog);
              },
            ),
            new ListTile(
              leading: new Icon(
                Icons.block,
                color: UIData.red,
              ),
              title: new Text(
                block,
                style: TextStyle(color: UIData.blackOrWhite),
              ),
              onTap: () {
                if (isBlocked) {
                  firestoreInstance
                      .document(
                          "users/${widget.user.id}/blocked/${userProfile.id}")
                      .delete();
                  setState(() {
                    block = "Block";
                    isBlocked = false;
                  });
                } else if (!isBlocked) {
                  firestoreInstance
                      .document(
                          "users/${widget.user.id}/blocked/${userProfile.id}")
                      .setData({"name": userProfile.userName});
                  block = "Unblock";
                  isBlocked = true;
                }
                // setState(() {});
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
    showDialog(context: context, child: dialog);
  }

  Widget resultsButton() {
    if (!ownProfile) {
      return Padding(
        padding: EdgeInsets.only(
          right: 16,
        ),
        child: new ConstrainedBox(
          constraints: BoxConstraints(minWidth: 60.0, minHeight: 30.0),
          child: new RaisedButton(
              child: new Text(followOrEdit,
                  style: new TextStyle(color: Colors.black, fontSize: 16.0)),
              shape: new RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              color: UIData.yellowOrWhite,
              textColor: Colors.black,
              elevation: 8.0,
              onPressed: () {
                if (userProfile.shareResults && widget.user.subLevel > 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResultPage(
                                user: userProfile,
                                currentUser: widget.user,
                                isLoading: true,
                              )));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Subscription(
                                user: userProfile,
                                title: "Subscriptions",
                              )));
                }
              }),
        ),
      );
    } else {
      return new Container();
    }
  }

  Widget addImage() {
    ImageProvider<dynamic> imageProvider;

    if (userProfile.profilePicURL != null) {
      ownProfile
          ? imageProvider =
              CachedNetworkImageProvider(userProfile.profilePicURL)
          : imageProvider = NetworkImage(userProfile.profilePicURL);
    }
    if (widget.user.image != null) {
      return new CircleAvatar(
        radius: 35,
        backgroundImage: FileImage(widget.user.image),
        backgroundColor: Colors.grey[600],
      );
    } else if (userProfile.profilePicURL == null) {
      return new CircleAvatar(
        radius: 35,
        child: Icon(
          Icons.person_outline,
          color: UIData.blackOrWhite,
          size: 40,
        ),
        backgroundColor: Colors.grey[600],
      );
    } else {
      return new CircleAvatar(
        radius: 35,
        backgroundImage: imageProvider,
        backgroundColor: UIData.darkest,
      );
    }
  }

  Widget notSharing(String type) {
    return new Padding(
        padding: EdgeInsets.all(10.0),
        child: new Align(
          alignment: Alignment.topCenter,
          child: new Container(
            decoration: new BoxDecoration(
                color: UIData.listColor,
                border: Border.all(color: UIData.darkest),
                borderRadius: new BorderRadius.all(const Radius.circular(8.0))),
            child: new Padding(
                padding: EdgeInsets.all(10.0),
                child: new Text(
                  "${userProfile.userName} has chosen to not share $type results",
                  style:
                      new TextStyle(fontSize: 25.0, color: UIData.blackOrWhite),
                )),
          ),
        ));
  }

  Widget subRequired() {
    return new Padding(
        padding: EdgeInsets.all(10.0),
        child: new Align(
          alignment: Alignment.topCenter,
          child: new Container(
            height: 180,
            decoration: new BoxDecoration(
                color: UIData.listColor,
                border: Border.all(color: Colors.grey[600]),
                borderRadius: new BorderRadius.all(const Radius.circular(8.0))),
            child: new Padding(
                padding: EdgeInsets.all(10.0),
                child: new Column(
                  children: <Widget>[
                    new Text(
                      "A subscription is required to view game history",
                      style: new TextStyle(
                        fontSize: 25.0,
                        color: UIData.blackOrWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.0),
                    SizedBox(
                      width: 240.0,
                      height: 50.0,
                      child: PrimaryButton(
                        text: "Subscribe",
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Subscription(
                                      user: widget.user,
                                      title: "Subscription",
                                    ))),
                      ),
                    ),
                  ],
                )),
          ),
        ));
  }

  Widget setCashStream() {
    if (widget.user.subLevel < 1) {
      return subRequired();
    } else if (userProfile.shareResults || ownProfile) {
      return cashGameStream();
    } else {
      return notSharing("cash game");
    }
  }

  Widget setTournamentStream() {
    if (widget.user.subLevel < 1) {
      return subRequired();
    } else if (userProfile.shareResults || ownProfile) {
      return tournamentStream();
    } else {
      return notSharing("tournament");
    }
  }

  Widget cashGameList(BuildContext context, DocumentSnapshot document) {
    Color color;
    String name = document.data["groupname"];
    String currency = document.data["currency"];
    int profit = document.data["profit"];

    if (profit.isNegative) {
      color = Colors.red;
    } else {
      color = Colors.green;
    }
    if (name.length > 13) {
      name = name.substring(0, 10);
      name = name + "...";
    }
    if (currency.length >= 6) {
      currency = currency.substring(0, 3);
      currency = currency + "...";
    }
    String str = profit.toString();
    if (str.length >= 12) {
      str = str.substring(0, 9);
      str = str + "...";
    }
    return ListTile(
      contentPadding: EdgeInsets.all(3.0),
      leading: new Icon(
        Icons.attach_money,
        color: color,
        size: 40.0,
      ),
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(
            name,
            textAlign: TextAlign.start,
            style: new TextStyle(color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
          ),
          new Text(
            "${document.data["day"]}/${document.data["month"]}/${document.data["year"]} ${document.data["time"]}",
            style: new TextStyle(color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
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
            "Profit: $str$currency",
            style: new TextStyle(color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      onTap: () => toResults(document.data, "Cash Game"),
    );
  }

  Widget cashGameStream() {
    if (qSnapCash != null) {
      if (qSnapCash.documents.isEmpty) {
        return new Text("...");
      } else {
        List<DocumentSnapshot> list = qSnapCash.documents;
        List<DocumentSnapshot> finalList = new List();
        for (var item in list) {
          if (item.data["share"] == true) {
            finalList.add(item);
          }
        }

        return ListView.builder(
          itemExtent: 50.0,
          itemCount: finalList.length,
          itemBuilder: (context, index) =>
              cashGameList(context, finalList[index]),
        );
      }
    } else {
      return new Container();
    }
  }

  Widget tournamentList(BuildContext context, DocumentSnapshot document) {
    Color color;
    String name = document.data["groupname"];
    String currency = document.data["currency"];
    String profit = document.data["profit"].toString();

    if (int.tryParse(profit).isNegative) {
      color = Colors.red;
    } else {
      color = Colors.green;
    }
    if (name.length > 13) {
      name = name.substring(0, 10);
      name = name + "...";
    }
    if (currency.length >= 6) {
      currency = currency.substring(0, 3);
      currency = currency + "...";
    }
    if (profit.length >= 11) {
      profit = profit.substring(0, 9);
      profit = profit + "...";
    }
    return ListTile(
      contentPadding: EdgeInsets.all(3.0),
      leading: new Icon(
        Icons.whatshot,
        color: color,
        size: 40.0,
      ),
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(
            name,
            textAlign: TextAlign.start,
            style: new TextStyle(color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
          ),
          new Text(
            "${document.data["day"]}/${document.data["month"]}/${document.data["year"]} ${document.data["time"]}",
            style: new TextStyle(color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
      subtitle: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(
            "Placing: ${document.data["placing"]}/${document.data["playeramount"]}",
            textAlign: TextAlign.start,
            style: new TextStyle(color: UIData.blackOrWhite),
          ),
          new Text(
            "Profit: $profit$currency",
            style: new TextStyle(color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      onTap: () => toResults(document.data, "Tournament"),
    );
  }

  void toResults(
    Map<String, dynamic> map,
    String title,
  ) {
    ResultGame result = new ResultGame.fromMap(map);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePageResults(
                  user: widget.user,
                  result: result,
                  title: title,
                )));
  }

  Widget tournamentStream() {
    if (qSnapTournament != null) {
      if (qSnapTournament.documents.isEmpty) {
        return new Text("...");
      } else {
        List<DocumentSnapshot> list = qSnapTournament.documents;
        List<DocumentSnapshot> finalList = new List();
        for (var item in list) {
          if (item.data["share"] == true) {
            finalList.add(item);
          }
        }

        return ListView.builder(
          itemExtent: 50.0,
          itemCount: finalList.length,
          itemBuilder: (context, index) =>
              tournamentList(context, finalList[index]),
        );
      }
    } else {
      return new Container();
    }
  }
}
