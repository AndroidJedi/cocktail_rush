import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AlcIndicator extends StatelessWidget{

  String _alc;

  AlcIndicator(this._alc);

  @override
  Widget build(BuildContext context) {
   return Center(child: Text('$_alc %', style: TextStyle(fontSize: 15.0, color: Colors.purple)));
  }

}