import 'dart:io';

class User {
  User(
    this.email,
    this.id,
    this.userName,
    this.fcm,
    this.bio,
    this.nightMode,
    this.shareResults,
    this.following,
    this.followers,
    this.hasProfilePic,
    this.profilePicURL,
  );

  final String userName;
  final String id;
  final String email;
  final String fcm;
  String bio;
  String profilePicURL;
  bool nightMode;
  bool shareResults;
  int following;
  int followers;
  bool hasProfilePic;

  String getToken() {
    return this.fcm;
  }

  String getName() {
    return this.userName;
  }

  String getId() {
    return this.id;
  }

  String getEmail() {
    return this.email;
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'name': this.userName,
        'email': this.email,
        'fcm': this.fcm,
        'bio': this.bio,
        'nightmode': this.nightMode,
        'shareresults': this.shareResults,
        'following': this.following,
        'followers': this.followers,
        'profilepicurl': this.profilePicURL
      };
}
