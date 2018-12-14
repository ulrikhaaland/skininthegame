import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/auth.dart';
import 'package:yadda/utils/uidata.dart';
import 'invite_page.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/user_profile/profile_page_settings.dart';
import 'package:yadda/utils/essentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:yadda/utils/ProfilePic.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ProfilePage extends StatefulWidget {
  ProfilePage(
      {Key key,
      this.auth,
      this.onSignOut,
      this.user,
      this.setGroupPage,
      this.profileId})
      : super(key: key);
  final BaseAuth auth;
  final String profileId;
  final VoidCallback onSignOut;
  final VoidCallback setGroupPage;
  final User user;

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  TabController _tabController;
  final Firestore firestoreInstance = Firestore.instance;

  bool userFound = false;

  String followOrEdit = "Edit";

  bool ownProfile = false;

  User userProfile;

  double profileBGSize;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 4);

    if (widget.user.id == widget.profileId) {
      followOrEdit = "Edit";
      ownProfile = true;
    } else {
      followOrEdit = "Follow";
    }
    getUserInfo();
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
            await ProfilePicture().downloadFile(docSnap.data["id"], false));
        setState(() {
          userFound = true;
        });
      });
    }
    userFound = true;
    setBGSize();
  }

  void setBGSize() {
    setState(() {
      if (userProfile.bio.length <= 42) {
        profileBGSize = 230;
      } else if (userProfile.bio.length <= 87) {
        profileBGSize = 250;
      } else if (userProfile.bio.length <= 131) {
        profileBGSize = 270;
      } else {
        profileBGSize = 280;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userFound == true) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: UIData.appBarColor,
          iconTheme: IconThemeData(color: UIData.appBarColor),
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
                    Padding(
                      padding: EdgeInsets.only(
                        right: 16,
                      ),
                      child: new ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: 60.0, minHeight: 30.0),
                        child: new RaisedButton(
                            child: new Text(followOrEdit,
                                style: new TextStyle(
                                    color: Colors.black, fontSize: 16.0)),
                            shape: new RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0))),
                            color: UIData.yellowOrWhite,
                            textColor: Colors.black,
                            elevation: 8.0,
                            onPressed: () {
                              if (ownProfile) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileSettingsPage(
                                              user: widget.user,
                                              setBGSize: () => setBGSize(),
                                            )));
                              }
                            }),
                      ),
                    ),
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
                new Row(
                  children: <Widget>[
                    RaisedButton(
                      elevation: 0,
                      color: UIData.appBarColor,
                      child: new Row(
                        children: <Widget>[
                          new Text(
                            "Following",
                            style: new TextStyle(color: Colors.grey[600]),
                          ),
                          new Text(
                            " ${userProfile.following}",
                            style: new TextStyle(color: UIData.blackOrWhite),
                          ),
                        ],
                      ),
                      onPressed: () => print(""),
                    ),
                    RaisedButton(
                      elevation: 0,
                      color: UIData.appBarColor,
                      child: new Row(
                        children: <Widget>[
                          new Text(
                            "Followers",
                            style: new TextStyle(color: Colors.grey[600]),
                          ),
                          new Text(
                            " ${userProfile.followers}",
                            style: new TextStyle(color: UIData.blackOrWhite),
                          ),
                        ],
                      ),
                      onPressed: () => print(""),
                    ),
                  ],
                ),
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

  Widget addImage() {
    // if (userProfile.profilePic == null) {
    //   return new CircleAvatar(
    //     radius: 35,
    //     child: Icon(
    //       Icons.person_outline,
    //       size: 40,
    //     ),
    //     backgroundColor: Colors.grey[600],
    //   );
    // } else {
    return new CircleAvatar(
      radius: 35,
      backgroundImage: new CachedNetworkImageProvider(
          "https://firebasestorage.googleapis.com/v0/b/login-5a8c9.appspot.com/o/VboR4LOOM6Z3buxZ0JjnoMycfHI2?alt=media&token=c80471f1-c1d3-4c22-b60d-9fc0fa092241"),
      backgroundColor: Colors.grey[600],
    );
    // }
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

  Widget setCashStream() {
    if (userProfile.shareResults || ownProfile) {
      return cashGameStream();
    } else {
      return notSharing("cash game");
    }
  }

  Widget setTournamentStream() {
    if (userProfile.shareResults || ownProfile) {
      return tournamentStream();
    } else {
      return notSharing("tournament");
    }
  }

  Widget cashGameList(BuildContext context, DocumentSnapshot document) {
    Color color;
    String name = document.data["groupname"];
    String currency = document.data["currency"];
    String profit = document.data["profit"];

    if (int.tryParse(document.data["profit"]).isNegative) {
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
    if (profit.length >= 12) {
      profit = profit.substring(0, 9);
      profit = profit + "...";
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
            "${document.data["date"]} - ${document.data["time"]} - ${document.data["year"]}",
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
            "Profit: $profit$currency",
            style: new TextStyle(color: UIData.blackOrWhite),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      onTap: null,
    );
  }

  Widget cashGameStream() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("users/${userProfile.id}/cashgameresults")
            .orderBy("orderbytime", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return new Text("...");
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                cashGameList(context, snapshot.data.documents[index]),
          );
        });
  }

  Widget tournamentList(BuildContext context, DocumentSnapshot document) {
    Color color;
    String name = document.data["groupname"];
    String currency = document.data["currency"];
    String profit = document.data["profit"];

    if (int.tryParse(document.data["profit"]).isNegative) {
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
            "${document.data["time"]} - ${document.data["date"]} - ${document.data["year"]}",
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
      onTap: null,
    );
  }

  Widget tournamentStream() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("users/${userProfile.id}/tournamentresults")
            .orderBy("orderbytime", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return new Text("...");
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                tournamentList(context, snapshot.data.documents[index]),
          );
        });
  }
}
