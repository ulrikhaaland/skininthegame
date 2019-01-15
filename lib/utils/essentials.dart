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
