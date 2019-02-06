import 'package:flutter/material.dart';

import 'package:yadda/utils/uidata.dart';

class Essentials extends StatelessWidget {
  Widget loading(bool isLoading) {
    if (isLoading == true) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new Container();
    }
  }

  Widget setScreen(Widget widget, bool loading) {
    if (loading == true) {
      return Essentials();
    } else {
      return widget;
    }
  }

  showSnackBar(String message, BuildContext context) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      backgroundColor: UIData.yellow,
      content: new Text(
        message,
        textAlign: TextAlign.center,
        style: new TextStyle(color: Colors.black),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIData.appBarColor,
      ),
      backgroundColor: UIData.dark,
      body: loading(true),
    );
  }
}
