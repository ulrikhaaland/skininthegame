import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:yadda/utils/log.dart';
import 'package:yadda/objects/game.dart';

class CashGamePlayerPage extends StatefulWidget {
  CashGamePlayerPage(
      {Key key,
      this.playerId,
      this.playerUserName,
      this.user,
      this.buyinAmount,
      this.group,
      this.history,
      this.callBack,
      this.payout,
      this.game})
      : super(key: key);
  final User user;
  final Group group;
  final String playerId;
  final String playerUserName;
  final int buyinAmount;
  final int payout;
  final Game game;
  final bool history;
  final VoidCallback callBack;

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

  setBuyin() {
    if (validateAndSave()) {
      firestoreInstance
          .document("$gamePath/players/${widget.playerId}")
          .updateData({"buyin": newPlayerBuyinAmount, 'payout': newPayout});
      // firestoreInstance
      //     .document(
      //         "$gamePath/activeplayers/${widget.playerId}")
      //     .updateData({"buyin": newPlayerBuyinAmount, 'payout': newPayout});

      if (oldPlayerBuyinAmount != newPlayerBuyinAmount) {
        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} buyin amount from $oldPlayerBuyinAmount to $newPlayerBuyinAmount",
            "$gamePath/log",
            "Buyin");
      }

      if (oldPayout != newPayout) {
        Log().postLogToCollection(
            "$currentUserName changed ${widget.playerUserName} payout amount from $oldPayout to $newPayout",
            "$gamePath/log",
            "Payout");
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
            leading: new Icon(
              Icons.person,
              size: 40.0,
              color: Colors.blue,
            ),
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
              Icons.delete,
              size: 40.0,
              color: UIData.red,
            ),
            title: new Text(
              "Remove Player",
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
            ),
            onTap: () {
              if (widget.history == true) {
                firestoreInstance.runTransaction((Transaction tx) async {
                  await firestoreInstance
                      .document("$gamePath/players/${widget.playerId}")
                      .delete();
                });
              }
              firestoreInstance
                  .document("$gamePath/activeplayers/${widget.playerId}")
                  .delete();
              widget.callBack();
              Log().postLogToCollection(
                  "$currentUserName removed ${widget.playerUserName} from game",
                  "$gamePath/log",
                  "Remove");

              Navigator.pop(context);
            },
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
            title: new TextFormField(
              keyboardType: TextInputType.number,
              style: new TextStyle(color: UIData.blackOrWhite),
              initialValue: oldPlayerBuyinAmount.toString(),
              decoration: InputDecoration(
                labelStyle: new TextStyle(color: Colors.grey[600]),
                labelText: "Total buyin amount",
              ),
              onSaved: (val) => newPlayerBuyinAmount = int.tryParse(val),
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
              onSaved: (val) => newPayout = int.tryParse(val),
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
            leading: new Icon(
              Icons.person,
              size: 40.0,
              color: Colors.blue,
            ),
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

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
      child: child,
    );
  }
}
