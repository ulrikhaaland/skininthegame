import 'dart:async';
import 'package:yadda/utils/uidata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'package:yadda/objects/user.dart';
import 'package:yadda/objects/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/essentials.dart';
import 'subLevel.dart';
import 'TermsAndConditions.dart';

class Subscription extends StatefulWidget {
  Subscription(
      {Key key, this.title, this.user, this.onUpdate, this.group, this.info})
      : super(key: key);
  final User user;
  final VoidCallback onUpdate;
  final String title;
  final Group group;
  final bool info;

  @override
  _SubscriptionState createState() => new _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  static List<String> iapId = ["shark", "whale"];

  String fishTitle = "YOUR PLAN";
  String sharkTitle = "";
  String whaleTitle = "";

  bool activeShark = false;
  bool activeWhale = false;

  List<IAPItem> _items = [];
  bool loading = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() async {
    super.dispose();
    await FlutterInappPurchase.endConnection;
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
    List<IAPItem> items = await FlutterInappPurchase.getSubscriptions(iapId);
    int subLevel;
    widget.user.subLevel == null
        ? subLevel = await SubLevel().getSubLevel()
        : subLevel = widget.user.subLevel;

    items[0].body = "light";
    items[1].body = "medium";

    this._items.add(items[0]);
    this._items.add(items[1]);

    if (subLevel > 0) {
      fishTitle = "FREE";
    }
    subLevel == 1
        ? sharkTitle = "YOUR PLAN"
        : sharkTitle = '${_items[0].price} ${_items[0].currency} PER MONTH';
    if (subLevel == 2) {
      whaleTitle = "YOUR PLAN";
      sharkTitle = '${_items[0].price} ${_items[0].currency} PER MONTH';
    } else {
      whaleTitle = '${_items[1].price} ${_items[1].currency} PER MONTH';
    }
    loading = false;
    setState(() {});
  }

  Future<Null> _buySubscription(IAPItem item) async {
    try {
      setState(() {
        isLoading = true;
      });
      PurchasedItem purchased =
          await FlutterInappPurchase.buySubscription(item.productId);
      print(purchased.transactionReceipt);
      if (purchased.transactionReceipt.isNotEmpty) {
        if (item.productId == "whale") {
          widget.user.subLevel = 2;
        }
        if (item.productId == "shark") {
          widget.user.subLevel = 1;
        }
        Firestore.instance.document("users/${widget.user.id}").updateData({
          'sublevel': widget.user.subLevel,
        });
        Navigator.pop(context);
      }
    } catch (error) {
      print('$error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget fishPlan() {
    return Card(
      color: UIData.listColor,
      elevation: 3,
      // padding: EdgeInsets.only(
      //   bottom: 24.0,
      // ),
      child: Column(
        children: <Widget>[
          SizedBox(height: 12.0),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Fish Plan (FREE)",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize24,
              ),
            ),
          ),
          SizedBox(height: 12.0),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 12.0, right: 12.0),
              child: new Column(
                children: <Widget>[
                  Text(
                    "9 players per tournament",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "6 players per cashgame",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "Limited to 3 groups",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sharkPlan() {
    return Card(
      color: UIData.listColor,
      elevation: 3,
      child: Column(
        children: <Widget>[
          SizedBox(height: 12.0),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Shark Plan",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize24,
              ),
            ),
          ),
          SizedBox(height: 12.0),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 12.0, right: 12.0),
              child: new Column(
                children: <Widget>[
                  Text(
                    "Everything from Fish Plan",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "27 players per tournament",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "9 players per cashgame",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "Limited to 10 groups",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "Enable notifications",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "Ad free",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "Track your own and other players results",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.center,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  SizedBox(height: 24.0),
                  SizedBox(
                    width: 240.0,
                    height: 50.0,
                    child: PrimaryButton(
                      onPressed: () => _buySubscription(_items[0]),
                      text: sharkTitle,
                    ),
                  ),
                  new Align(
                    alignment: Alignment.center,
                    child: new Container(
                      width: 300,
                      child: new Column(
                        children: <Widget>[
                          SizedBox(height: 12.0),
                          new Text(
                            "Recurring billing. Cancel anytime.",
                            style: new TextStyle(color: Colors.grey[600]),
                          ),
                          FlatButton(
                            child: new Text(
                              "Terms & Conditions",
                              style: new TextStyle(color: UIData.blackOrWhite),
                            ),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TermsAndConditions())),
                          ),
                          new Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: new Text(
                              "The subscription will automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period. You can go to your iTunes Account settings to manage your subscriptions and turn off auto-renew. Your iTunes Account will be charged when the purchase is confirmed.",
                              style: new TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget whalePlan() {
    return Card(
      color: UIData.listColor,
      elevation: 3,
      // padding: EdgeInsets.only(
      //   bottom: 24.0,
      // ),
      child: Column(
        children: <Widget>[
          SizedBox(height: 12.0),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Whale Plan",
              style: new TextStyle(
                color: UIData.blackOrWhite,
                fontSize: UIData.fontSize24,
              ),
            ),
          ),
          SizedBox(height: 12.0),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 12.0, right: 12.0),
              child: new Column(
                children: <Widget>[
                  Text(
                    "Everything from Shark Plan",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "Unlimited players per tournament",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "Unlimited players per cashgame",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  Text(
                    "Unlimited groups",
                    style:
                        TextStyle(fontSize: 16.0, color: UIData.blackOrWhite),
                    textAlign: TextAlign.left,
                  ),
                  Divider(
                    height: 4,
                    color: UIData.blackOrWhite,
                  ),
                  SizedBox(height: 24.0),
                  SizedBox(
                    width: 240.0,
                    height: 50.0,
                    child: PrimaryButton(
                      onPressed: () => _buySubscription(_items[1]),
                      text: whaleTitle,
                    ),
                  ),
                  new Align(
                    alignment: Alignment.center,
                    child: new Container(
                      width: 300,
                      child: new Column(
                        children: <Widget>[
                          SizedBox(height: 12.0),
                          new Text(
                            "Recurring billing. Cancel anytime.",
                            style: new TextStyle(color: Colors.grey[600]),
                          ),
                          FlatButton(
                            child: new Text(
                              "Terms & Conditions",
                              style: new TextStyle(color: UIData.blackOrWhite),
                            ),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TermsAndConditions())),
                          ),
                          new Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: new Text(
                              "The subscription will automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period. You can go to your iTunes Account settings to manage your subscriptions and turn off auto-renew. Your iTunes Account will be charged when the purchase is confirmed.",
                              style: new TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                ],
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
                            color: UIData.blackOrWhite,
                            fontSize: UIData.fontSize24),
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
                        onPressed: () => null,
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
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          children: <Widget>[
            information(),
            SizedBox(height: 24.0),
            whalePlan(),
            SizedBox(height: 24.0),
            sharkPlan(),
            SizedBox(height: 24.0),
            fishPlan(),
          ],
        ),
      );

  Widget information() {
    if (widget.info == true) {
      return Card(
        color: UIData.listColor,
        elevation: 3,
        // padding: EdgeInsets.only(
        //   bottom: 24.0,
        // ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.title,
                style: new TextStyle(
                  color: UIData.red,
                  fontSize: UIData.fontSize16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 12.0),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loading)
      return new Scaffold(
        backgroundColor: UIData.dark,
        appBar: new AppBar(
          iconTheme: IconThemeData(color: UIData.blackOrWhite),
          backgroundColor: UIData.appBarColor,
          title: new Text(
            "Subscriptions",
            style: new TextStyle(
                fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
          ),
        ),
        body: Stack(
          children: <Widget>[
            allCards(context),
            Essentials().loading(isLoading),
          ],
        ),
      );
    else
      return new Essentials();
  }
}
