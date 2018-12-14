import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class GroupLeft {
  Firestore firestoreInstance = Firestore.instance;

  Future<bool> checkMembersLeft(String groupId) async {
    int i = 0;
    bool isAllowedMoreMembers;
    DocumentSnapshot docSnap =
        await firestoreInstance.document("groups/$groupId").get();
    await firestoreInstance.runTransaction((Transaction tx) async {
      QuerySnapshot qSnap = await firestoreInstance
          .collection("groups/$groupId/members")
          .getDocuments();
      qSnap.documents.forEach((DocumentSnapshot doc) {
        i++;
      });
      if (docSnap.data["memberslimit"] > i) {
        isAllowedMoreMembers = true;
      } else {
        isAllowedMoreMembers = false;
      }
    });
    return isAllowedMoreMembers;
  }

  Future<bool> checkAmountLeft(String groupId, String type) async {
    bool isAllowed;
    DocumentSnapshot docSnap =
        await firestoreInstance.document("groups/$groupId").get();
    if (docSnap.data["$type"] <= 0) {
      isAllowed = false;
    } else {
      isAllowed = true;
    }
    return isAllowed;
  }
}
