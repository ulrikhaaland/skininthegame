import 'package:flutter/material.dart';

class Provider extends InheritedWidget {
  Provider({Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static Provider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(Provider) as Provider);
  }
}
