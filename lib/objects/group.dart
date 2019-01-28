import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  Group(
      this.name,
      this.dailyMessage,
      this.host,
      this.id,
      this.info,
      this.lowerCaseName,
      this.members,
      this.public,
      this.rating,
      this.admin,
      this.numberOfCashGames,
      this.numberOfTournaments,
      this.shareResults);

  Firestore firestoreInstance = Firestore.instance;

  String name;
  String id;
  String host;
  String lowerCaseName;
  String dailyMessage;
  String info;
  int members;
  double rating;
  int numberOfTournaments;
  int numberOfCashGames;

  bool admin;
  bool public;
  bool shareResults;

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'name': this.name,
        'host': this.host,
        'lowercasename': this.lowerCaseName,
        'dailymessage': this.dailyMessage,
        'info': this.info,
        'members': this.members,
        'rating': this.rating,
        'admin': this.admin,
        'public': this.public,
        'numberoftournaments': this.numberOfTournaments,
        'numberofcashgames': this.numberOfCashGames,
        "shareresults": this.shareResults,
      };

  pushGroupToFirestore(String path) {
    DocumentReference docRef = firestoreInstance.document(path);
    firestoreInstance.runTransaction((Transaction tx) async {
      await docRef.setData(toJson());
    });
  }

  void setPublic(bool public) {
    this.public = public;
    firestoreInstance.runTransaction((Transaction tx) async {
      await firestoreInstance.document("groups/$id").updateData({
        'public': public,
      });
    });
  }

  void setShareResults(bool shareResults) {
    this.shareResults = shareResults;
    firestoreInstance.runTransaction((Transaction tx) async {
      await firestoreInstance.document("groups/$id").updateData({
        'shareresults': shareResults,
      });
    });
  }

  void setRating(double rating) {
    this.rating = rating;
  }

  int getNumberOfTournaments() {
    return this.numberOfTournaments;
  }

  int getNumberOfCashGames() {
    return this.numberOfCashGames;
  }

  void setDailyMessage(String message) {
    this.dailyMessage = message;
  }

  int getMembers() {
    return this.members;
  }

  bool isAdmin() {
    return this.admin;
  }

  double getRating() {
    return this.rating;
  }

  bool isPublic() {
    return this.public;
  }

  String getDailyMessage() {
    return this.dailyMessage;
  }

  String getName() {
    return this.name;
  }

  String getId() {
    return this.id;
  }

  String getHost() {
    return this.host;
  }

  String getLowerCaseName() {
    return this.lowerCaseName;
  }

  String getInfo() {
    return this.info;
  }
}
