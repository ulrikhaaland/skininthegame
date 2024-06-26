import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';

class Delete {
  Firestore firestoreInstance = Firestore.instance;

  deleteCollection(String collectionPath, int batchSize) async {
    // firestoreInstance.runTransaction((Transaction tx) async {
    return await firestoreInstance
        .collection(collectionPath)
        .limit(batchSize)
        .getDocuments()
        .then((datasnapshot) {
      int deleted = 0;
      if (datasnapshot.documents.isNotEmpty) {
        for (int i = 0; i < datasnapshot.documents.length; i++) {
          String data = datasnapshot.documents[i].documentID;

          firestoreInstance.document("$collectionPath/$data").delete();
          deleted++;
        }
        if (deleted != 0) {
          // retrieve and delete another batch
          deleteCollection(collectionPath, batchSize);
        }
      }
    });
    // });
  }

  Future<bool> deleteAllGroupMembers(String groupId) async {
    QuerySnapshot qSnap = await firestoreInstance
        .collection("groups/$groupId/members")
        .getDocuments();
    qSnap.documents.forEach((DocumentSnapshot doc) {
      firestoreInstance
          .document("users/${doc.documentID}/groups/$groupId")
          .delete();
    });
    return true;
  }

  deleteAllGroupGames(String groupId) async {
    for (int c = 0; c <= 3; c++) {
      String collectionType;
      switch (c) {
        case (0):
          collectionType = "cashgameactive";
          break;
        case (1):
          collectionType = "cashgamehistory";
          break;
        case (2):
          collectionType = "tournamentactive";
          break;
        case (3):
          collectionType = "tournamenthistory";
          break;
      }
      for (int i = 0; i <= 4; i++) {
        String collection;
        switch (i) {
          case (0):
            collection = "players";
            break;
          case (1):
            collection = "activeplayers";
            break;
          case (2):
            collection = "posts";
            break;
          case (3):
            collection = "log";
            break;
          case (4):
            collection = "queue";
            break;
        }
        QuerySnapshot querySnapshot = await firestoreInstance
            .collection("groups/$groupId/games/type/$collectionType")
            .getDocuments();
        querySnapshot.documents.forEach((DocumentSnapshot doc) async {
          deleteCollection(
              "groups/$groupId/games/type/$collectionType/${doc.documentID}/$collection",
              5);

          if (i == 4) {
            firestoreInstance
                .document(
                    "groups/$groupId/games/type/$collectionType/${doc.documentID}")
                .delete();
          }
        });
      }
    }
  }

  Future<Null> deleteGroup(String groupId) async {
    QuerySnapshot qSnap = await firestoreInstance
        .collection("groups/$groupId/members")
        .getDocuments();
    qSnap.documents.forEach((doc) async {
      await firestoreInstance
          .document("users/${doc.documentID}/groups/$groupId")
          .delete();
    });
    await firestoreInstance.document("codes/$groupId").delete();
    var resp = await CloudFunctions()
        .call(functionName: "recursiveDeleteGroup", parameters: {
      "path": "groups/$groupId",
      "groupId": groupId,
    });
    print(resp);
    return null;
  }

  Future<Null> deleteUser(String uid) async {
    QuerySnapshot qSnap =
        await firestoreInstance.collection("users/$uid/groups").getDocuments();
    qSnap.documents.forEach((doc) async {
      await firestoreInstance
          .document("groups/${doc.documentID}/members/$uid")
          .delete();
    });
    firestoreInstance.document("usernames/$uid").delete();
    var resp = await CloudFunctions()
        .call(functionName: "recursiveDeleteUser", parameters: {
      "path": "users/$uid",
      "uid": uid,
    });
    print(resp);
    return null;
  }
}
