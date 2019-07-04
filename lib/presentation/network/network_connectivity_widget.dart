//import 'dart:async';
//
//import 'package:cocktail_rush/lockalization/CrLocalization.dart';
//import 'package:flutter/material.dart';
//import 'package:connectivity/connectivity.dart';
//
//class NetworkConnectivityWidget extends StatefulWidget {
//  final Widget child;
//
//  NetworkConnectivityWidget({this.child});
//
//  @override
//  _NetworkConnectivityWidgetState createState() =>
//      _NetworkConnectivityWidgetState();
//}
//
//class _NetworkConnectivityWidgetState extends State<NetworkConnectivityWidget>
//    with SingleTickerProviderStateMixin {
//  AnimationController controller;
//  StreamSubscription subscription;
//
//  @override
//  void initState() {
//    super.initState();
//    subscription = Connectivity()
//        .onConnectivityChanged
//        .listen((ConnectivityResult result) {
//      if (result == ConnectivityResult.none) {
//        controller.forward();
//      } else {
//        controller.reverse();
//      }
//    });
//    controller = AnimationController(
//        duration: const Duration(milliseconds: 200), vsync: this);
//
//    final Animation curve =
//        CurvedAnimation(parent: controller, curve: Curves.easeOut);
//
//    curve
//      ..addListener(() {
//        setState(() {});
//      });
//  }
//
//  @override
//  void dispose() {
//    super.dispose();
//    subscription.cancel();
//    controller.dispose();
//
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      child: Column(
//        children: <Widget>[
//          Expanded(
//            child: Container(
//                height:
//                    MediaQuery.of(context).size.height - 30.0 * controller.value,
//                child: widget.child),
//          ),
//          Container(
//              height: 30.0 * controller.value,
//              width: double.infinity,
//              color: Colors.purple[900],
//              child: Center(
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: [
//                    Icon(Icons.cloud_off, color: Colors.white),
//                    SizedBox(
//                      width: 8,
//                    ),
//                    Text(CrLocalization.of(context).offline,
//                        style: Theme.of(context).textTheme.title)
//                  ],
//                ),
//              )),
//        ],
//      ),
//    );
//  }
//}
