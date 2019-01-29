import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubLevel {
  Future<bool> groupsLeft(String uid, int subLevel) async {
    bool tru;
    QuerySnapshot qSnap =
        await Firestore.instance.collection("users/$uid/groups").getDocuments();
    switch (subLevel) {
      case (0):
        {
          qSnap.documents.length > 2 ? tru = false : tru = true;
        }
        break;
      case (1):
        {
          qSnap.documents.length > 9 ? tru = false : tru = true;
        }
        break;
    }
    return tru;
  }

  Future<int> howManyGroupsLeft(String uid, int subLevel) async {
    QuerySnapshot qSnap =
        await Firestore.instance.collection("users/$uid/groups").getDocuments();
    int groupsLeft;
    switch (subLevel) {
      case (0):
        {
          groupsLeft = 3 - qSnap.documents.length;
        }
        break;
      case (1):
        {
          groupsLeft = 10 - qSnap.documents.length;
        }
        break;
    }
    return groupsLeft;
  }

  bool checkIfHasGroupLeft(int subLevel, int groupsLeft) {
    bool tru;
    switch (subLevel) {
      case (0):
        {
          groupsLeft < 1 ? tru = false : tru = true;
        }
        break;
      case (1):
        {
          groupsLeft < 9 ? tru = false : tru = true;
        }
        break;
    }
    return tru;
  }

  Future<int> getSubLevel() async {
    var result = await FlutterInappPurchase.initConnection;
    print('result: $result');

    int subLevel;

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
