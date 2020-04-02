library connection_status_bar;

import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class CustomConnectionStatusBar extends StatefulWidget {
  final Color color;
  final Widget
      title; // lo ho tolto pero si puo mettere sostistuendo il Text() a riga 82 con widget.title
  final double width;
  final double height;

  CustomConnectionStatusBar({
    Key key,
    this.height = 25,
    this.width = double.maxFinite,
    this.color = Colors.redAccent,
    this.title = const Text(
      'Please check your internet connection',
      style: TextStyle(color: Colors.white, fontSize: 14),
    ),
  }) : super(key: key);

  _CustomConnectionStatusBarState createState() =>
      _CustomConnectionStatusBarState();
}

class _CustomConnectionStatusBarState extends State<CustomConnectionStatusBar> {
  bool _hasConnection = true;
  @override
  void initState() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _hasConnection = false;
      } else {
        _hasConnection = true;
      }
      if (mounted) setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: _hasConnection ? Colors.transparent : widget.color,
          ),
          width: widget.width,
          height: widget.height,
          child: Center(
            child: _hasConnection
                ? Offstage()
                : Text(
                    'Offline',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

var subscription;
