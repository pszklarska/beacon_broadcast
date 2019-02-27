import 'dart:async';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAdvertising = false;
  StreamSubscription<bool> _isAdvertisingSubscription;

  @override
  void initState() {
    super.initState();
    _isAdvertisingSubscription = BeaconBroadcast.listenForStateChange().listen((isAdvertising) {
      setState(() {
        _isAdvertising = isAdvertising;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  BeaconBroadcast.start();
                },
                child: Text('START'),
              ),
              RaisedButton(
                onPressed: () {
                  BeaconBroadcast.stop();
                },
                child: Text('STOP'),
              ),
              Text('Current state: $_isAdvertising')
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_isAdvertisingSubscription != null) {
      _isAdvertisingSubscription.cancel();
    }
  }
}
