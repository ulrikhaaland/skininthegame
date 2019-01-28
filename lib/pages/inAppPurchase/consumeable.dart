import 'dart:async';
import 'package:yadda/utils/uidata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/essentials.dart';

class Consumeable extends StatefulWidget {
  Consumeable({Key key, this.title, this.user, this.onUpdate, this.group})
      : super(key: key);
  final User user;
  final VoidCallback onUpdate;
  final String title;
  final Group group;

  @override
  _ConsumeableState createState() => new _ConsumeableState();
}

class _ConsumeableState extends State<Consumeable> {
  static List<String> iapId = [];

  String groupBody = "";
  String groupTitle = "";

  String light;
  String medium;
  String large;

  String topBody;
  String topTitle;

  String freePlan;
  List<IAPItem> _items = [];
  bool loading = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    purchaseMembers();
    purchaseTournaments();
    purchaseCashGames();
    purchaseAdmins();
  }

  purchaseAdmins() {
    if (widget.title == "Admins") {
      iapId = [
        'com.yadda.adminslight',
        "com.yadda.adminsmedium",
        "com.yadda.adminslarge"
      ];
      light = "Increase the limit by 3." +
          "\n\nYour group will be able to host a total of { + 3} Admins.";
      medium = "Increase the limit by 9." +
          "\n\nYour group will be able to host a total of { + 9} Admins.";
      large = "Increase the limit by 30." +
          "\n\nYour group will be able to host a total of { + 30} Admins.";
      topBody =
          "Your group has reached its limit of admins. Increase the limit to host more admins.";
      topTitle = "Out of Admins!";
    }
  }

  void increaseAdminsLimit(IAPItem item) {
    int increaseLimitBy;
    switch (item.productId) {
      case ("com.yadda.adminslight"):
        {
          increaseLimitBy = 3;
        }
        break;
      case ("com.yadda.adminsmedium"):
        {
          increaseLimitBy = 9;
        }
        break;
      case ("com.yadda.adminslarge"):
        {
          increaseLimitBy = 30;
        }
        break;
    }
    Firestore.instance.runTransaction((Transaction tx) async {
      var current =
          await Firestore.instance.document("groups/${widget.group.id}").get();
      await Firestore.instance
          .document("groups/${widget.group.id}")
          .updateData({
        'adminsleft': current.data["adminsleft"] + increaseLimitBy,
      });
    });
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  purchaseCashGames() {
    if (widget.title == "Cash Games") {
      iapId = [
        'com.yadda.cashgameslight',
        "com.yadda.cashgamesmedium",
        "com.yadda.cashgameslarge"
      ];
      light = "Increase the limit by 5." +
          "\n\nYour group will be able to host a total of  + 5} Cash Games.";
      medium = "Increase the limit by 15." +
          "\n\nYour group will be able to host a total of  + 15} Cash Games.";
      large = "Increase the limit by 50." +
          "\n\nYour group will be able to host a total of  + 50} Cash Games.";
      topBody =
          "Your group has reached its limit of Cash Games. Increase the limit to host more Cash Games.";
      topTitle = "Out of Cash Games!";
    }
  }

  void increaseCashGameLimit(IAPItem item) {
    int increaseLimitBy;
    switch (item.productId) {
      case ("com.yadda.cashgamelight"):
        {
          increaseLimitBy = 5;
        }
        break;
      case ("com.yadda.cashgamemedium"):
        {
          increaseLimitBy = 15;
        }
        break;
      case ("com.yadda.cashgamelarge"):
        {
          increaseLimitBy = 50;
        }
        break;
    }
    Firestore.instance.runTransaction((Transaction tx) async {
      var current =
          await Firestore.instance.document("groups/${widget.group.id}").get();
      await Firestore.instance
          .document("groups/${widget.group.id}")
          .updateData({
        'cashgamesleft': current.data["cashgamesleft"] + increaseLimitBy,
      });
    });
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void increaseTournamentLimit(IAPItem item) {
    int increaseLimitBy;
    switch (item.productId) {
      case ("com.yadda.tournamentlight"):
        {
          increaseLimitBy = 5;
        }
        break;
      case ("com.yadda.tournamentmedium"):
        {
          increaseLimitBy = 15;
        }
        break;
      case ("com.yadda.tournamentlarge"):
        {
          increaseLimitBy = 50;
        }
        break;
    }
    Firestore.instance.runTransaction((Transaction tx) async {
      var current =
          await Firestore.instance.document("groups/${widget.group.id}").get();
      await Firestore.instance
          .document("groups/${widget.group.id}")
          .updateData({
        'tournamentsleft': current.data["tournamentsleft"] + increaseLimitBy,
      });
    });
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  purchaseTournaments() {
    if (widget.title == "Tournaments") {
      iapId = [
        'com.yadda.tournamentlight',
        "com.yadda.tournamentmedium",
        "com.yadda.tournamentlarge"
      ];
      light = "Increase the limit by 5." +
          "\n\nYour group will be able to host a total of  + 5} tournaments.";
      medium = "Increase the limit by 15." +
          "\n\nYour group will be able to host a total of  + 15} tournaments.";
      large = "Increase the limit by 50." +
          "\n\nYour group will be able to host a total of  + 50} tournaments.";
      topBody =
          "Your group has reached its limit of tournaments. Increase the limit to host more tournaments.";
      topTitle = "Out of tournaments!";
    }
  }

  void increaseMemberLimit(IAPItem item) {
    int increaseLimitBy;
    switch (item.productId) {
      case ("com.yadda.memberslight"):
        {
          increaseLimitBy = 10;
        }
        break;
      case ("com.yadda.membersmedium"):
        {
          increaseLimitBy = 30;
        }
        break;
      case ("com.yadda.memberslarge"):
        {
          increaseLimitBy = 100;
        }
        break;
    }
    Firestore.instance.runTransaction((Transaction tx) async {
      var current =
          await Firestore.instance.document("groups/${widget.group.id}").get();
      await Firestore.instance
          .document("groups/${widget.group.id}")
          .updateData({
        'memberslimit': current.data["memberslimit"] + increaseLimitBy,
      });
    });
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void purchaseMembers() {
    if (widget.title == "Members") {
      iapId = [
        'com.yadda.memberslight',
        "com.yadda.membersmedium",
        "com.yadda.memberslarge"
      ];
      light = "Increase the limit by 10 members." +
          "\n\nYour group will be able to host a total of  members.";
      medium = "Increase the limit by 30 members." +
          "\n\nYour group will be able to host a total of  members.";
      large = "Increase the limit by 100 members." +
          "\n\nYour group will be able to host a total of  members.";
      topBody =
          "Your group has reached its limit of  members. Increase the limit to add more members.";
      topTitle = "Your group is full!";
    }
  }

  Future<void> initPlatformState() async {
    // prepare
    var result = await FlutterInappPurchase.initConnection;
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // refresh items for android
    String msg = await FlutterInappPurchase.consumeAllItems;
    print('consumeAllItems: $msg');
    // await _getAvailablePurchases();
    await _getProduct();
  }

  Future<Null> _getProduct() async {
    List<IAPItem> items = await FlutterInappPurchase.getProducts(iapId);

    items[1].body = light;
    items[2].body = medium;
    items[0].body = large;

    this._items.add(items[1]);
    this._items.add(items[2]);
    this._items.add(items[0]);

    // for (var item in items) {
    //   if (item.productId.contains("light")) {
    //     item.body = light;
    //   } else if (item.productId.contains("medium")) {
    //     item.body = medium;
    //   } else if (item.productId.contains("large")) {
    //     item.body = large;
    //   }
    // }
    loading = false;
    setState(() {});
  }

  Future<Null> _buyProduct(IAPItem item) async {
    try {
      setState(() {
        isLoading = true;
      });
      PurchasedItem purchased =
          await FlutterInappPurchase.buyProduct(item.productId);
      print(purchased.transactionReceipt);
      if (purchased.transactionReceipt.isNotEmpty) {
        increaseMemberLimit(item);
      }
      String msg = await FlutterInappPurchase.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (error) {
      print('$error');
    }
  }

  Widget freeGroup() {
    return Container(
      padding: EdgeInsets.only(
        bottom: 24.0,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: 12.0),
          Align(
            alignment: Alignment.center,
            child: Text(
              topTitle,
              style: new TextStyle(
                color: UIData.white,
                fontSize: UIData.fontSize24,
              ),
            ),
          ),
          SizedBox(height: 12.0),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 12.0, right: 12.0),
              child: Text(
                topBody,
                style: TextStyle(fontSize: 16.0, color: UIData.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderButton() {
    List<Widget> widgets = this
        ._items
        .map(
          (item) => Container(
                padding: EdgeInsets.only(
                  bottom: 24.0,
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${item.title}',
                        style: new TextStyle(
                            color: UIData.white, fontSize: UIData.fontSize24),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(left: 12.0, right: 12.0),
                        child: Text(
                          item.body,
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    SizedBox(
                      width: 340.0,
                      height: 50.0,
                      child: PrimaryButton(
                        onPressed: () => _buyProduct(item),
                        text: '${item.price} ${item.currency}',
                      ),
                    ),
                  ],
                ),
              ),
        )
        .toList();
    return widgets;
  }

  Widget itemsForPurchase(BuildContext context) =>
      Column(children: this._renderButton());

  Widget allCards(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        child: Column(
          children: <Widget>[
            freeGroup(),
            Divider(
              color: UIData.darkest,
              height: 0,
            ),
            itemsForPurchase(context),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: UIData.darkest,
        title: new Text(
          widget.title,
          style: new TextStyle(fontSize: UIData.fontSize24),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Essentials().setScreen(allCards(context), loading),
          Essentials().loading(isLoading),
        ],
      ),
    );
  }
}
