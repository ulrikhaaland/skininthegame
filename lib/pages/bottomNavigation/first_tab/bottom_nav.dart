import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/auth.dart';
import 'package:yadda/pages/bottomNavigation/second_tab/game_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/root_page.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/pages/profile/profile_page.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/utils/layout.dart';
import 'package:yadda/utils/groupLeft.dart';
import 'package:yadda/widgets/primary_button.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage(
      {this.auth,
      this.onSignOut,
      this.currentUser,
      this.userEmail,
      this.userName,
      this.user});
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final String currentUser;
  final String userName;
  final String userEmail;
  final User user;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Key keyOne = PageStorageKey('pageOne');
  final Key keyTwo = PageStorageKey('pageTwo');
  final Key keyThree = PageStorageKey('pageThree');
  // final Key keyThree = PageStorageKey('pageThree');

  final BaseAuth auth = Auth();

  Firestore firestoreInstance = Firestore.instance;

  int currentTab = 0;

  String currentUser;

  String profileId;

  PageOne two;
  GamePage one;
  ProfilePage three;
  // DisplaySearch three;
  List<Widget> pages;
  Widget currentPage;

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    print(widget.user.getName());
    two = PageOne(
      key: keyOne,
      auth: auth,
      user: widget.user,
    );

    one = GamePage(
        key: keyTwo,
        auth: auth,
        user: widget.user,
        setProfilePage: () => setProfilePage(),
        onSignOut: () => _signOut(),
        changeColor: () => settate());

    three = ProfilePage(
      key: keyTwo,
      auth: auth,
      setGroupPage: () => setGroupPage(),
      onSignOut: () => _signOut(),
      user: widget.user,
      profileId: widget.user.id,
    );

    pages = [one, two, three];

    currentPage = one;

    super.initState();
    // setPage();
  }

  void _signOut() async {
    try {
      await auth.signOut();
      widget.onSignOut();
    } catch (e) {
      print(e);
    }
  }

  void settate() {
    setState(() {});
  }

  setProfilePage() {
    setState(() {
      currentTab = 0;
      currentPage = three;
    });
  }

  setGroupPage() {
    setState(() {
      currentTab = 0;
      currentPage = one;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIData.darkest,
      body: PageStorage(
        child: currentPage,
        bucket: bucket,
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        type: BottomNavigationBarType.shifting,
        currentIndex: currentTab,
        onTap: (int index) {
          setState(() {
            currentTab = index;
            currentPage = pages[index];
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.group,
              color: UIData.yellow,
            ),
            backgroundColor: UIData.darkest,
            icon: Icon(
              Icons.group,
              color: Colors.grey[600],
            ),
            title: Text(
              "Groups",
              style: new TextStyle(color: UIData.blackOrWhite),
            ),
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.search,
              color: UIData.yellow,
            ),
            backgroundColor: UIData.darkest,
            icon: Icon(
              Icons.search,
              color: Colors.grey[600],
            ),
            title: Text(
              'Find',
              style: new TextStyle(color: UIData.blackOrWhite),
            ),
          ),

          // BottomNavigationBarItem(
          //   activeIcon: Icon(
          //     Icons.settings,
          //     color: UIData.yellow,
          //   ),
          //   backgroundColor: UIData.darkest,
          //   icon: Icon(
          //     Icons.settings,
          //     color: Colors.grey[600],
          //   ),
          //   title: Text(
          //     "Settings",
          //     style: new TextStyle(color: UIData.blackOrWhite),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class PageOne extends StatefulWidget {
  PageOne({Key key, this.auth, this.onSignOut, this.user}) : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final User user;

  @override
  PageOneState createState() => PageOneState();
}

class PageOneState extends State<PageOne> {
  static final formKey = new GlobalKey<FormState>();

  String groupCode = "ererasdas";
  String groupName;
  String groupId;

  String userName;

  Firestore firestoreInstance = Firestore.instance;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIData.dark,
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIData.appBarColor,
        title: new Text(
          "Find Group",
          style: new TextStyle(
              fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
        ),
      ),
      body: new Form(
          key: formKey,
          child: new Stack(
            children: <Widget>[
              page(),
              loading(),
            ],
          )),
    );
  }

  Widget loading() {
    if (isLoading == true) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new Container();
    }
  }

  Widget page() {
    return new ListView(children: <Widget>[
      Layout().padded(
        child: TextField(
          style: new TextStyle(color: UIData.blackOrWhite),
          decoration: InputDecoration(
            fillColor: UIData.white,
            labelText: 'Enter group code',
            labelStyle: new TextStyle(color: Colors.grey[600]),
            icon: new Icon(
              Icons.group,
              size: 40.0,
              color: Colors.grey[600],
            ),
          ),
          onChanged: (String value) {
            onChanged(value);
          },
        ),
      ),
      Layout().padded(
        child: new PrimaryButton(
            color: UIData.yellow,
            text: "Join",
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              String typeOfCode;
              if (groupCode.contains("r")) {
                typeOfCode = "reusablegroupcode";
              } else if (groupCode.contains("a")) {
                typeOfCode = "admingroupcode";
              } else if (groupCode.contains("o")) {
                typeOfCode = "code";
              }
              _getGroup(typeOfCode);
            }),
      ),
    ]);
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  _getGroup(String typeOfCode) {
    firestoreInstance
        .collection("codes")
        .where("$typeOfCode", isEqualTo: groupCode)
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.isNotEmpty) {
        setState(() {
          List<DocumentSnapshot> map = snapshot.documents.toList();
          DocumentSnapshot string = map[0];
          groupId = string.data["groupid"];
          groupName = string.data["groupname"];
          _saveGroup();
          print("true");
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Scaffold.of(formKey.currentState.context).showSnackBar(new SnackBar(
          backgroundColor: UIData.yellow,
          content: new Text(
            "Group code does not exist",
            textAlign: TextAlign.center,
            style: new TextStyle(color: Colors.black),
          ),
        ));
      }
    });
  }

  void _saveGroup() async {
    bool allowed = await GroupLeft().checkMembersLeft(groupId);
    await firestoreInstance.runTransaction((Transaction tx) async {
      if (allowed == true) {
        bool admin;
        if (groupCode.contains("r")) {
        } else if (groupCode.contains("o")) {
          firestoreInstance
              .document(
                  "groups/$groupId/codes/onetimegroupcode/codes/$groupCode")
              .delete();
          firestoreInstance.document("codes/$groupCode").delete();
        } else if (groupCode.contains("a")) {
          await firestoreInstance.runTransaction((Transaction tx) async {
            DocumentSnapshot docSnap =
                await firestoreInstance.document("groups/$groupId").get();
            if (docSnap.data["adminsleft"] < 1) {
              admin = false;
            } else {
              admin = true;
            }
          });
        }
        firestoreInstance
            .document("groups/$groupId/members/${widget.user.id}")
            .setData({
          "uid": widget.user.id,
          "username": widget.user.userName,
          "admin": admin,
          "notification": true,
          "fcm": widget.user.fcm
        });
        firestoreInstance
            .document("users/${widget.user.id}/groups/$groupId")
            .setData({
          "id": groupId,
          "name": groupName,
          "numberofcashgames": 0,
          "numberoftournaments": 0,
          "members": 0,
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RootPage(
                    auth: widget.auth,
                  )),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        Scaffold.of(formKey.currentState.context).showSnackBar(new SnackBar(
          backgroundColor: UIData.yellow,
          content: new Text(
            "This group has reached its limit of members",
            textAlign: TextAlign.center,
            style: new TextStyle(color: Colors.black),
          ),
        ));
      }
    });
  }

  void onChanged(String value) {
    setState(() {
      groupCode = value;
    });
    print(groupCode);
  }
}
