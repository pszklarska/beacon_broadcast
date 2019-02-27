import 'dart:async';

import 'package:flutter/services.dart';

class BeaconBroadcast {
  static const MethodChannel _methodChannel =
      const MethodChannel('pl.pszklarska.beaconbroadcast/beacon_state');

  static const EventChannel _eventChannel =
      const EventChannel('pl.pszklarska.beaconbroadcast/beacon_events');

  static Future<void> start() async {
    await _methodChannel.invokeMethod('start');
  }

  static Future<void> stop() async {
    await _methodChannel.invokeMethod('stop');
  }

  static Future<bool> isStarted() async {
    return await _methodChannel.invokeMethod('isStarted');
  }

  static Stream<bool> listenForStateChange() {
    return _eventChannel.receiveBroadcastStream().cast<bool>();
  }
}
