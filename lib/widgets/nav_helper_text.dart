import 'package:flutter/material.dart';

List<Widget> addNav(List<String> navItems, BuildContext context) {
  List<Widget> list = List();
  for (int i = 0; i < navItems.length; i++) {
    debugPrint(i.toString());
    switch (navItems.length - i - 1) {
      case (0):
        list.add(GestureDetector(
          child: Text(
            navItems[i],
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          onTap: () => Navigator.pop(context),
        ));
        break;
      case (1):
        list.add(GestureDetector(
          child: Text(
            navItems[i],
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          onTap: () => Navigator.of(context)..pop()..pop(),
        ));
        break;
      case (2):
        list.add(GestureDetector(
          child: Text(
            navItems[i],
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          onTap: () => Navigator.of(context)..pop()..pop()..pop(),
        ));
        break;
      case (3):
        list.add(GestureDetector(
          child: Text(
            navItems[i],
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          onTap: () => Navigator.of(context)..pop()..pop()..pop()..pop(),
        ));
        break;
      case (4):
        list.add(GestureDetector(
          child: Text(
            navItems[i],
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          onTap: () => Navigator.of(context)..pop()..pop()..pop()..pop()..pop(),
        ));
        break;
      case (5):
        list.add(GestureDetector(
          child: Text(
            navItems[i],
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          onTap: () =>
              Navigator.of(context)..pop()..pop()..pop()..pop()..pop()..pop(),
        ));
        break;
      case (6):
        list.add(GestureDetector(
          child: Text(
            navItems[i],
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          onTap: () => Navigator.of(context)
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop(),
        ));
        break;
      case (7):
        list.add(GestureDetector(
          child: Text(
            navItems[i],
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          onTap: () => Navigator.of(context)
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop(),
        ));
        break;
      case (8):
        list.add(GestureDetector(
          child: Text(
            navItems[i],
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          onTap: () => Navigator.of(context)
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop()
            ..pop(),
        ));
        break;
    }
  }
  int length = list.length;
  for (var i = 0; i < length; i++) {
    int pos = i + 1;
    if (length > pos) {
      list.insert(
          pos,
          Text(
            ">",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ));
    }
  }

  return list;
}
