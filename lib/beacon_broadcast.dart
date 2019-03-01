// Copyright (c) <2019> <Paulina Szklarska>
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
  int _majorId;
  int _minorId;
  int _transmissionPower;
  String _identifier = "";

  static const MethodChannel _methodChannel =
      const MethodChannel('pl.pszklarska.beaconbroadcast/beacon_state');

  static const EventChannel _eventChannel =
      const EventChannel('pl.pszklarska.beaconbroadcast/beacon_events');

  /// Sets UUID for beacon.
  ///
  /// [uuid] is random string identifier, e.g. "2f234454-cf6d-4a0f-adf2-f4911ba9ffa6"
  ///
  /// This parameter is required
  BeaconBroadcast setUUID(String uuid) {
    _uuid = uuid;
    return this;
  }

  /// Sets major id for beacon.
  ///
  /// [majorId] is integer identifier with range between 1 and 65535
  ///
  /// This parameter is required
  BeaconBroadcast setMajorId(int majorId) {
    _majorId = majorId;
    return this;
  }

  /// Sets minor id for beacon.
  ///
  /// [minorId] is integer identifier with range between 1 and 65535
  ///
  /// This parameter is required
  BeaconBroadcast setMinorId(int minorId) {
    _minorId = minorId;
    return this;
  }

  /// Sets identifier for beacon.
  ///
  /// This parameter is **iOS only** (it has no effect on Android). It's string that identifies
  /// beacon additionally. You can check more info in article
  /// [Turning an iOS Device into an iBeacon](https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon)
  ///
  /// This parameter is optional
  BeaconBroadcast setIdentifier(String identifier) {
    _identifier = identifier;
    return this;
  }

  /// Sets transmission power for beacon.
  ///
  /// Transmission power determines strength of the signal transmitted by beacon. It's measured in
  /// dBm. Higher values amplify the signal strength, but also increase power usage.
  ///
  /// This parameter is optional, if not set, the default value for Android will be -59dB and for
  /// iOS the default received signal strength indicator (RSSI) value associated with the iOS device
  /// (see this article for more: [Turning an iOS Device into an iBeacon](https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon)
  BeaconBroadcast setTransmissionPower(int transmissionPower) {
    _transmissionPower = transmissionPower;
    return this;
  }

  /// Starts beacon advertising.
  ///
  /// Before starting you can set parameters such as [_uuid], [_majorId], [_minorId], [_identifier], [_transmissionPower].
  /// Parameters [_uuid], [_majorId], [_minorId] are required.
  ///
  /// For Android, beacon layout is set to AltBeacon (check more details here: [AltBeacon - Transmitting as a Beacon](https://altbeacon.github.io/android-beacon-library/beacon-transmitter.html)).
  /// On Android system, it's required to have Bluetooth turn on and to give app permission to location.
  ///
  /// For iOS, beacon is broadcasting as an iBeacon (check more details here: [Turning an iOS Device into an iBeacon](https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon))
  /// Note that according to the article: "After advertising your app as a beacon, your app must
  /// continue running in the foreground to broadcast the needed Bluetooth signals. If the user
  /// quits the app, the system stops advertising the device as a peripheral over Bluetooth.
  Future<void> start() async {
    if (_uuid == null ||
        _uuid.isEmpty ||
        _majorId == null ||
        _minorId == null) {
      throw new IllegalArgumentException(
          "Illegal arguments! UUID, majorId and minorId must not be null or empty: "
          "UUID: $_uuid, majorId: $_majorId, minorId: $_minorId");
    }

    Map params = <String, dynamic>{
      "uuid": _uuid,
      "majorId": _majorId,
      "minorId": _minorId,
      "transmissionPower": _transmissionPower,
      "identifier": _identifier,
    };

    await _methodChannel.invokeMethod('start', params);
  }

  /// Stops beacon advertising
  Future<void> stop() async {
    await _methodChannel.invokeMethod('stop');
  }

  /// Returns `true` if beacon is advertising
  Future<bool> isAdvertising() async {
    return await _methodChannel.invokeMethod('isAdvertising');
  }

  /// Returns Stream of booleans indicating if beacon is advertising.
  ///
  /// After listening to this Stream, you'll be notified about changes in beacon advertising state.
  /// Returns `true` if beacon is advertising. See also: [isAdvertising()]
  Stream<bool> getAdvertisingStateChange() {
    return _eventChannel.receiveBroadcastStream().cast<bool>();
  }

  /// Checks if device supports transmission. For iOS it returns always true.
  ///
  /// Possible values (for Android):
  /// * [BeaconStatus.SUPPORTED] device supports transmission
  /// * [BeaconStatus.NOT_SUPPORTED_MIN_SDK] Android system version on the device is lower than 21
  /// * [BeaconStatus.NOT_SUPPORTED_BLE] BLE is not supported on this device
  /// * [BeaconStatus.NOT_SUPPORTED_CANNOT_GET_ADVERTISER] device does not have a compatible chipset
  /// or driver
  Future<BeaconStatus> checkTransmissionSupported() async {
    var isTransmissionSupported =
        await _methodChannel.invokeMethod('isTransmissionSupported');
    return fromInt(isTransmissionSupported);
  }
}

class IllegalArgumentException implements Exception {
  final message;

  IllegalArgumentException(this.message);

  String toString() {
    return "IllegalArgumentException: $message";
  }
}

enum BeaconStatus {
  /// Device supports transmitting as a beacon
  SUPPORTED,

  /// Android system version on the device is too low (min. is 21)
  NOT_SUPPORTED_MIN_SDK,

  /// Device doesn't support Bluetooth Low Energy
  NOT_SUPPORTED_BLE,

  /// Device's Bluetooth chipset or driver doesn't support transmitting
  NOT_SUPPORTED_CANNOT_GET_ADVERTISER
}

BeaconStatus fromInt(int value) {
  switch (value) {
    case 0:
      return BeaconStatus.SUPPORTED;
    case 1:
      return BeaconStatus.NOT_SUPPORTED_MIN_SDK;
    case 2:
      return BeaconStatus.NOT_SUPPORTED_BLE;
    default:
      return BeaconStatus.NOT_SUPPORTED_CANNOT_GET_ADVERTISER;
  }
}
