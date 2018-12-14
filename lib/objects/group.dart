import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';

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
      this.membersLimit,
      this.adminsLeft,
      this.cashGamesLeft,
      this.tournamentsLeft,
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
  int cashGamesLeft;
  int tournamentsLeft;
  int adminsLeft;
  int postsLeft;
  int membersLimit;
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
        "cashgamesleft": this.cashGamesLeft,
        "tournamentsleft": this.tournamentsLeft,
        "adminsleft": this.adminsLeft,
        "postsleft": this.postsLeft,
        "memberslimit": this.membersLimit,
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

  void setCashGamesLeft(int cashGamesLeft) {
    this.cashGamesLeft = cashGamesLeft;
  }

  int getCashGamesLeft() {
    return this.cashGamesLeft;
  }

  void setTournamentsLeft(int tournamentsLeft) {
    this.tournamentsLeft = tournamentsLeft;
  }

  int getTournamentsLeft() {
    return this.tournamentsLeft;
  }

  void setAdminsLeft(int adminsLeft) {
    this.adminsLeft = adminsLeft;
  }

  int getAdminsLeft() {
    return this.adminsLeft;
  }

  void setMembersLimit(int membersLimit) {
    this.membersLimit = membersLimit;
  }

  int getMembersLimit() {
    return this.membersLimit;
  }

  void setPostsLeft(int postsLeft) {
    this.postsLeft = postsLeft;
  }

  int getPostsLeft() {
    return this.postsLeft;
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
