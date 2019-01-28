import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'dart:async';

class SubLevel {
  Future<int> getSubLevel() async {
    // prepare
    var result = await FlutterInappPurchase.initConnection;
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    int subLevel;
    // refresh items for android
    String msg = await FlutterInappPurchase.consumeAllItems;
    print('consumeAllItems: $msg');
    bool activeWhale = await FlutterInappPurchase.checkSubscribed(sku: "whale");
    if (activeWhale) {
      subLevel = 2;
    } else {
      bool activeShark =
          await FlutterInappPurchase.checkSubscribed(sku: "shark");
      activeShark ? subLevel = 1 : subLevel = 0;
    }
    FlutterInappPurchase.endConnection;
    return subLevel;
  }
}
