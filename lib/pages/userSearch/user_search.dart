import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/pages/userSearch/search.dart';

import 'package:yadda/auth.dart';



SearchBar searchBar;
bool _fresh = false;

AppBar _buildAppBar(BuildContext context) {
  return new AppBar(
    title: new Text("Søk etter medlemmer"),
    actions: <Widget>[
      searchBar.getSearchAction(context),
    ],
  );
}

class DisplaySearch extends StatefulWidget {
  DisplaySearch({Key key, this.auth, this.onSignOut, this.currentUser})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final String currentUser;

  @override
  _DisplaySearchState createState() => new _DisplaySearchState();
}

class _DisplaySearchState extends State<DisplaySearch> {
  String _queryText;
  String currentUserId;
  String friendUsername;
  String friendEmail;
  String friendUserId;
  String searchedUserId;
  String mCurrentUser;

  initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: searchBar.build(context),
      body: _putInBody(),
    );
  }

  _getCurrentUser() async {
    mCurrentUser = await widget.auth.currentUser();
    print('Current user: ' + mCurrentUser);
  }

  Widget _fireSearch(String queryText) {
    try {
      return new StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .where("username", isEqualTo: queryText.toLowerCase())
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return new Text(
              'Loading...',
              style: new TextStyle(fontSize: 30.0),
            );
          return new ListView(
            children: snapshot.data.documents.map((document) {
              return new Column(
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.all(16.0),
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          document['username'],
                          style: new TextStyle(
                            fontSize: 35.0,
                          ),
                        ),
                        new IconButton(
                          icon: new Icon(Icons.person_add),
                          tooltip: "Legg til i spill",
                          iconSize: 30.0,
                          onPressed: () {
                             // Get friend user uid
                            searchedUserId = document["uid"];
                            debugPrint(searchedUserId);

                            _fetch();
                            
                          },
                        ),
                        new Divider(),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      );
    } catch (e) {
      return null;
    }
  }

// Add user to friend-list.
  void _add() {
    Map<String, String> data = <String, String>{
      "username": friendUsername,
      "uid": friendUserId
    };
    print(data[0]);
    Firestore.instance
        .document("users/$mCurrentUser/friends/$searchedUserId")
        .setData(data)
        .whenComplete(() {
      debugPrint("Document Added");
    }).catchError((e) => print(e));
  }

// get searched user data
  void _fetch() {
    Firestore.instance
        .document("users/$searchedUserId")
        .get()
        .then((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          friendUsername = datasnapshot.data["username"];
          friendEmail = datasnapshot.data["email"];
          friendUserId = datasnapshot.data["uid"];
          debugPrint("$friendUsername $friendEmail $friendUserId");
          _add();
        });
      } else {
        debugPrint(_queryText);
      }
      
    });
  }

  

  Widget _fireList() {
    return new Text("");
  }

  void onSubmitted(String value) {
    setState(() {
      _queryText = value;
      _fresh = true;
    });
  }

  _DisplaySearchState() {
    searchBar = new SearchBar(
      onSubmitted: onSubmitted,
      inBar: true,
      buildDefaultAppBar: _buildAppBar,
      setState: setState,
    );
  }
  Widget _putInBody() {
    if (_fresh) {
      return _fireSearch(_queryText);
    } else {
      return _fireList();
    }
  }

  
}
