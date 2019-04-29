import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UnavailableNetworkIndicator extends StatelessWidget {
  UnavailableNetworkIndicator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("No Network connection"),
    );
  }
}
