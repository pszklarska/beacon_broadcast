// Copyright (c) <2017> <Paulina Szklarska>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:async';

import 'package:flutter/services.dart';

class BeaconBroadcast {
  String _uuid;

  static const MethodChannel _methodChannel =
      const MethodChannel('pl.pszklarska.beaconbroadcast/beacon_state');

  static const EventChannel _eventChannel =
      const EventChannel('pl.pszklarska.beaconbroadcast/beacon_events');

  BeaconBroadcast setUUID(String uuid) {
    _uuid = uuid;
    return this;
  }

  Future<void> start() async {
    Map params = <String, dynamic>{
      "uuid": _uuid,
    };

    await _methodChannel.invokeMethod('start', params);
  }

  Future<void> stop() async {
    await _methodChannel.invokeMethod('stop');
  }

  Future<bool> isStarted() async {
    return await _methodChannel.invokeMethod('isStarted');
  }

  Stream<bool> listenForStateChange() {
    return _eventChannel.receiveBroadcastStream().cast<bool>();
  }
}
