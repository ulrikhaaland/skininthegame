import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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

  deleteGroup(String groupId) async {
    await deleteAllGroupMembers(groupId);
    deleteAllGroupGames(groupId);
    deleteCollection("groups/$groupId/codes/onetimegroupcode/codes", 5);
    firestoreInstance.document("groups/$groupId/codes/admingroupcode").delete();
    firestoreInstance
        .document("groups/$groupId/codes/reusablegroupcode")
        .delete();
    deleteCollection("groups/$groupId/codes/onetimegroupcode/codes", 5);
    deleteCollection("groups/$groupId/posts", 5);
    deleteCollection("groups/$groupId/thumbs", 5);
    deleteCollection("groups/$groupId/members", 5);
    firestoreInstance.document("codes/$groupId").delete();

    firestoreInstance.document("groups/$groupId").delete();
  }
}
