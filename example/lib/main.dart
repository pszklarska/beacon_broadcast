import 'dart:async';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const UUID = '39ED98FF-2900-441A-802F-9C398FC199D2';
  static const MAJOR_ID = 1;
  static const MINOR_ID = 100;
  static const TRANSMISSION_POWER = -59;
  // static const ADVERTISE_MODE = 0;
  static const ADVERTISE_MODE = AdvertiseMode.LOW_POWER;
  static const IDENTIFIER = 'com.example.myDeviceRegion';
  static const LAYOUT = BeaconBroadcast.ALTBEACON_LAYOUT;
  static const MANUFACTURER_ID = 0x0118;

  BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  BeaconStatus _isTransmissionSupported;
  bool _isAdvertising = false;
  StreamSubscription<bool> _isAdvertisingSubscription;

  @override
  void initState() {
    super.initState();
    beaconBroadcast.checkTransmissionSupported().then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });

    _isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
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
          title: const Text('Beacon Broadcast'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Is transmission supported?',
                    style: Theme.of(context).textTheme.headline5),
                Text('$_isTransmissionSupported',
                    style: Theme.of(context).textTheme.subtitle1),
                Container(height: 16.0),
                Text('Is beacon started?', style: Theme.of(context).textTheme.headline5),
                Text('$_isAdvertising', style: Theme.of(context).textTheme.subtitle1),
                Container(height: 16.0),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      beaconBroadcast
                          .setUUID(UUID)
                          .setMajorId(MAJOR_ID)
                          .setMinorId(MINOR_ID)
                          .setTransmissionPower(-59)
                          .setAdvertiseMode(ADVERTISE_MODE)
                          .setIdentifier(IDENTIFIER)
                          .setLayout(LAYOUT)
                          .setManufacturerId(MANUFACTURER_ID)
                          .start();
                    },
                    child: Text('START'),
                  ),
                ),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      beaconBroadcast.stop();
                    },
                    child: Text('STOP'),
                  ),
                ),
                Text('Beacon Data', style: Theme.of(context).textTheme.headline5),
                Text('UUID: $UUID'),
                Text('Major id: $MAJOR_ID'),
                Text('Minor id: $MINOR_ID'),
                Text('Tx Power: $TRANSMISSION_POWER'),
                Text('Advertise Mode Value: $ADVERTISE_MODE'),
                Text('Identifier: $IDENTIFIER'),
                Text('Layout: $LAYOUT'),
                Text('Manufacturer Id: $MANUFACTURER_ID'),
              ],
            ),
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
