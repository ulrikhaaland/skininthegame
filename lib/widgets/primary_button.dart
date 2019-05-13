import 'package:flutter/material.dart';
import '../service/service_provider.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton({
    this.key,
    this.text,
    this.onPressed,
    this.color,
  }) : super(key: key);
  final Key key;
  final String text;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          minWidth: ServiceProvider.instance.screenService
              .getPortraitWidthByPercentage(context, 80),
          minHeight: ServiceProvider.instance.screenService
              .getPortraitHeightByPercentage(context, 6)),
      child: RaisedButton(
          child:
              Text(text, style: TextStyle(color: Colors.black, fontSize: 20.0)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0))),
          color: color,
          textColor: Colors.black,
          elevation: 8.0,
          onPressed: onPressed),
    );
  }
}
