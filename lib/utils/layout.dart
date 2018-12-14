import 'package:flutter/material.dart';

class Layout {
  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
      child: child,
    );
  }

  Widget divider() {
    return new Divider(
      height: .0,
      color: Colors.black,
    );
  }
}
