import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/pages/profile/profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yadda/objects/game.dart';

class CashGamePlayerPage extends StatefulWidget {
  CashGamePlayerPage({
    Key key,
    this.playerId,
    this.playerUserName,
    this.user,
    this.buyinAmount,
    this.group,
    this.history,
    this.callBack,
    this.payout,
    this.game,
    this.url,
    this.createdPlayer,
  }) : super(key: key);
  final User user;
  final Group group;
  final String playerId;
  final String playerUserName;
  final String url;
  final int buyinAmount;
  final int payout;
  final Game game;
  final bool history;
  final VoidCallback callBack;
  final bool createdPlayer;

  @override
  CashGamePlayerPageState createState() => CashGamePlayerPageState();
}

class CashGamePlayerPageState extends State<CashGamePlayerPage> {
  static final formKey = new GlobalKey<FormState>();
  Firestore firestoreInstance = Firestore.instance;

  String currentUserId;
  String currentUserName;
  bool userFound = false;
  bool isLoading = false;
  int oldPlayerBuyinAmount;
  int newPlayerBuyinAmount;
  int oldPayout;
  int newPayout;

  String activeOrHistory = "cashgameactive";
  String gamePath;

  @override
  void initState() {
    super.initState();

    currentUserId = widget.user.getId();
    currentUserName = widget.user.getName();
    oldPlayerBuyinAmount = widget.buyinAmount;
    oldPayout = widget.payout;
    if (widget.history == true) {
      activeOrHistory = "cashgamehistory";
    }
    gamePath =
        "groups/${widget.group.id}/games/type/$activeOrHistory/${widget.game.id}";
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    setState(() {
      isLoading = false;
    });

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: UIData.blackOrWhite),
            actions: <Widget>[
              updateButton(),
            ],
            backgroundColor: UIData.appBarColor,
            title: new Text(
              "Cash Game Player",
              style: new TextStyle(
                  fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
            )),
        backgroundColor: UIData.dark,
        body: new Stack(
          children: <Widget>[
            new Form(
              key: formKey,
              child: page(),
            ),
            circular(),
          ],
        ));
  }

  Widget updateButton() {
    if (widget.group.admin == true) {
      return new FlatButton(
          child: new Text(
            "Update",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            setState(() {
              isLoading = true;
            });
            setBuyin();
          });
    } else {
      return new FlatButton(
        child: new Text(
          "",
          style: new TextStyle(
              fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          textAlign: TextAlign.center,
        ),
        onPressed: null,
      );
    }
  }

  Widget circular() {
    if (isLoading == true) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new Text("");
    }
  }

  setBuyin() async {
    if (validateAndSave()) {
      int buyinAmount = 0;
      int payoutAmount = 0;
      firestoreInstance
          .document("$gamePath/activeplayers/${widget.playerId}")
          .updateData({"buyin": newPlayerBuyinAmount, 'payout': newPayout});
      // firestoreInstance
      //     .document(
      //         "$gamePath/activeplayers/${widget.playerId}")
      //     .updateData({"buyin": newPlayerBuyinAmount, 'payout': newPayout});
      if (oldPayout != newPayout) {
        payoutAmount = newPayout - oldPayout;

        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} payout amount from $oldPayout to $newPayout",
            "$gamePath/log",
            "Payout");
      }
      if (oldPlayerBuyinAmount != newPlayerBuyinAmount) {
        buyinAmount = newPlayerBuyinAmount - oldPlayerBuyinAmount;

        if (widget.game.isRunning) {
          await firestoreInstance.runTransaction((Transaction tx) async {
            DocumentReference docRef = firestoreInstance.document(gamePath);

            DocumentSnapshot docSnap = await tx.get(docRef);
            int onTable = docSnap.data["moneyontable"] + buyinAmount;
            await tx.update(docRef, {'moneyontable': onTable});
          });
        }

        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} buyin amount from $oldPlayerBuyinAmount to $newPlayerBuyinAmount",
            "$gamePath/log",
            "Buyin");
      }
      if (buyinAmount != 0 || payoutAmount != 0) {
        await firestoreInstance.runTransaction((Transaction tx) async {
          DocumentReference docRef = firestoreInstance
              .document("$gamePath/players/${widget.playerId}");
          DocumentSnapshot docSnap = await tx.get(docRef);
          await tx.update(docRef, {
            "buyin": docSnap.data["buyin"] + buyinAmount,
            "payout": docSnap.data["payout"] + payoutAmount
          });
        });
      }
      setState(() {
        isLoading = false;
      });
    }
    Navigator.pop(context);
  }

  Widget page() {
    if (widget.group.admin == true) {
      return ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          new ListTile(
            leading: addImage(widget.url),
            title: new Text(
              "${widget.playerUserName}",
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              if (!widget.createdPlayer) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              user: widget.user,
                              profileId: widget.playerId,
                            )));
              }
            },
          ),
          new ListTile(
            leading: new Icon(
              Icons.attach_money,
              size: 40.0,
              color: UIData.green,
            ),
            title: new TextFormField(
              keyboardType: TextInputType.number,
              style: new TextStyle(color: UIData.blackOrWhite),
              initialValue: oldPlayerBuyinAmount.toString(),
              decoration: InputDecoration(
                labelStyle: new TextStyle(color: Colors.grey[600]),
                labelText: "Total buyin amount",
              ),
              onSaved: (val) => val.isEmpty
                  ? newPlayerBuyinAmount = 0
                  : newPlayerBuyinAmount = int.tryParse(val),
            ),
            onTap: null,
          ),
          new Text(
            "This amount equals to how much money the player has bought in for",
            style: new TextStyle(
                fontSize: UIData.fontSize12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          new ListTile(
            leading: new Icon(
              Icons.attach_money,
              size: 40.0,
              color: UIData.green,
            ),
            title: new TextFormField(
              keyboardType: TextInputType.number,
              style: new TextStyle(color: UIData.blackOrWhite),
              initialValue: oldPayout.toString(),
              decoration: InputDecoration(
                labelStyle: new TextStyle(color: Colors.grey[600]),
                labelText: "Payout",
              ),
              onSaved: (val) =>
                  val.isEmpty ? newPayout = 0 : newPayout = int.tryParse(val),
            ),
            onTap: null,
          ),
          new Text(
            "This amount equals to how much money the player had when player left the game",
            style: new TextStyle(
                fontSize: UIData.fontSize12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return new ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          new ListTile(
            leading: addImage(widget.url),
            title: new Text(
              "${widget.playerUserName}",
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          new Divider(
            height: .0,
            color: Colors.black,
          ),
          new ListTile(
            leading: new Icon(
              Icons.attach_money,
              size: 40.0,
              color: UIData.green,
            ),
            title: new Text(
              "Buyin: $oldPlayerBuyinAmount",
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
            ),
            onTap: null,
          ),
          new Divider(
            height: .0,
            color: Colors.black,
          ),
          new ListTile(
            leading: new Icon(
              Icons.attach_money,
              size: 40.0,
              color: UIData.green,
            ),
            title: new Text(
              "Payout: $oldPayout",
              style: new TextStyle(
                  fontSize: UIData.fontSize20, color: UIData.blackOrWhite),
            ),
            onTap: null,
          ),
        ],
      );
    }
  }

  Widget addImage(String url) {
    if (url != null) {
      return new CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(url),
        backgroundColor: Colors.grey[600],
      );
    } else {
      return new CircleAvatar(
        radius: 20,
        child: Icon(
          Icons.person_outline,
          color: Colors.white,
          size: 30,
        ),
        backgroundColor: Colors.grey[600],
      );
    }
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
      child: child,
    );
  }
}
