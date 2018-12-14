import 'package:flutter/material.dart';
import 'package:yadda/auth.dart';
import 'package:yadda/pages/login/login.dart';
import 'package:yadda/pages/group/group_pages/tournament/tournamentPages/tournament_page.dart';
import 'package:yadda/pages/bottomNavigation/first_tab/bottom_nav.dart';
import 'package:yadda/pages/group/group_pages/cashgame/cashgame_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils/essentials.dart';
import 'package:yadda/objects/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yadda/utils/util.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'utils/ProfilePic.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'dart:math';

import 'dart:typed_data';
import 'dart:io';
import 'dart:async';

class RootPage extends StatefulWidget {
  RootPage({Key key, this.auth}) : super(key: key);
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
  loading,
}

class RootPageState extends State<RootPage> {
  String currentUser;
  String userName;
  String userEmail;
  String messagingToken;
  User user;

  File _cachedFile;

  UIData uiData = new UIData();

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  AuthStatus authStatus = AuthStatus.loading;

  initState() {
    super.initState();

    getUserId();
    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print("onLaunch called");
      handleMessage(msg);
    }, onResume: (Map<String, dynamic> msg) {
      print("onResume called");
      handleMessage(msg);
    }, onMessage: (Map<String, dynamic> msg) {
      print("onMessage called");
      handleMessage(msg);
    });
    firebaseMessaging
        .requestNotificationPermissions(const IosNotificationSettings(
      sound: true,
      alert: true,
      badge: true,
    ));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print("IOS Setting Registered");
    });
  }

  Future<String> updateFcmToken() async {
    if (currentUser != null) {
      messagingToken = await firebaseMessaging.getToken();
      print(messagingToken);
      Firestore.instance
          .document("users/$currentUser")
          .updateData({"fcm": messagingToken});
    }
    return messagingToken;
  }

  void handleMessage(Map<String, dynamic> message) async {
    if (user == null) {
      user = await getUserInfo();
    }
    var gameType = getValueFromMap(message, 'gameType');
    var groupName = getValueFromMap(message, 'groupName');

    var fromGroupId = getValueFromMap(message, 'fromGroupId');
    var fromGameId = getValueFromMap(message, 'fromGameId');
    var dailyMessage = getValueFromMap(message, "dailyMessage");
    var host = getValueFromMap(message, "host");
    var info = getValueFromMap(message, "info");
    var lowerCaseName = getValueFromMap(message, "lowerCaseName");
    var docSnap = await Firestore.instance
        .document("groups/$fromGroupId/members/${user.id}")
        .get();
    var admin = docSnap.data["admin"];
    Group group = new Group(
        groupName,
        dailyMessage,
        host,
        fromGroupId,
        info,
        lowerCaseName,
        null,
        null,
        null,
        admin,
        null,
        null,
        null,
        null,
        null,
        null,
        null);
    if (gameType == "Tournament!") {
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => new TournamentPage(
                user: user,
                group: group,
                fromNotification: true,
                gameId: fromGameId,
              )));
    } else if (gameType == "Cash Game!") {
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => new CashGamePage(
                user: user,
                group: group,
                fromNotification: true,
                gameId: fromGameId,
              )));
    }
  }

  Future<String> getUserId() async {
    currentUser = await widget.auth.currentUser();
    await getUserInfo();
    return currentUser;
  }

  Future<Null> downloadFile(String uid) async {
    final String fileName = uid;
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$fileName');

    final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);

    final int byteNumber = (await downloadTask.future).totalByteCount;

    print(byteNumber);
    setState(() => _cachedFile = file);
  }

  Future<Null> getUserInfo() async {
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot docSnap =
          await Firestore.instance.document("users/$currentUser").get();
      if (docSnap.exists) {
        user = new User(
          docSnap.data["email"],
          docSnap.data["id"],
          docSnap.data["name"],
          await updateFcmToken(),
          docSnap.data["bio"],
          docSnap.data["nightmode"],
          docSnap.data["shareresults"],
          docSnap.data["following"],
          docSnap.data["followers"],
          null,
          // await ProfilePicture().downloadFile(docSnap.data["id"], true),
        );
        setState(() {
          authStatus = currentUser != null
              ? AuthStatus.signedIn
              : AuthStatus.notSignedIn;
        });
        uiData.nightMode(user.nightMode, user.id);
      } else {
        setState(() {
          authStatus = AuthStatus.notSignedIn;
        });
      }
    });
  }

  void _updateAuthStatus(AuthStatus status) {
    setState(() {
      authStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new Login(
          title: 'Flutter Login',
          messagingToken: messagingToken,
          auth: widget.auth,
          onSignIn: () => getUserId(),
        );
      case AuthStatus.signedIn:
        return new MyHomePage(
            auth: widget.auth,
            currentUser: currentUser,
            userEmail: userEmail,
            userName: userName,
            user: user,
            onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn));
      case AuthStatus.loading:
        return new Essentials();
    }
  }
}
