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
  static const String ALTBEACON_LAYOUT =
      'm:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25';
  static const String EDDYSTONE_TLM_LAYOUT =
      'x,s:0-1=feaa,m:2-2=20,d:3-3,d:4-5,d:6-7,d:8-11,d:12-15';
  static const String EDDYSTONE_UID_LAYOUT =
      's:0-1=feaa,m:2-2=00,p:3-3:-41,i:4-13,i:14-19';
  static const String EDDYSTONE_URL_LAYOUT =
      's:0-1=feaa,m:2-2=10,p:3-3:-41,i:4-21v';
  static const String URI_BEACON_LAYOUT =
      's:0-1=fed8,m:2-2=00,p:3-3:-41,i:4-21v';

  String _uuid;
  int _majorId;
  int _minorId;
  int _transmissionPower;
  int _advertiseMode;
  String _identifier = "";
  String _layout;
  int _manufacturerId;
  List<int> _extraData;

  static const MethodChannel _methodChannel =
      const MethodChannel('pl.pszklarska.beaconbroadcast/beacon_state');

  static const EventChannel _eventChannel =
      const EventChannel('pl.pszklarska.beaconbroadcast/beacon_events');

  /// Sets UUID for beacon.
  ///
  /// [uuid] is random string identifier, e.g. "2f234454-cf6d-4a0f-adf2-f4911ba9ffa6"
  ///
  /// This parameter is required for the default layout
  BeaconBroadcast setUUID(String uuid) {
    _uuid = uuid;
    return this;
  }

  /// Sets major id for beacon.
  ///
  /// [majorId] is integer identifier with range between 1 and 65535
  ///
  /// This parameter is required for the default layout
  BeaconBroadcast setMajorId(int majorId) {
    _majorId = majorId;
    return this;
  }

  /// Sets minor id for beacon.
  ///
  /// [minorId] is integer identifier with range between 1 and 65535
  ///
  /// This parameter is required for the default layout
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

  /// Sets advertise mode for beacon.
  ///
  /// Advertise mode determines advertising frequency and power consumption.
  ///
  /// This parameter is **Android only** (it has no effect on iOS). It is optional, if not set, the default value will be [AdvertiseMode.balanced].
  /// You can use one of the options:
  /// <ul>
  /// <li>[AdvertiseMode.lowPower] Consumes less energy, but larger broadcast interval
  /// <li>[AdvertiseMode.balanced] default: Balance between energy usage and broadcast interval
  /// <li>[AdvertiseMode.lowLatency] Consumes more energy, but smaller broadcast interval
  /// </ul>
  BeaconBroadcast setAdvertiseMode(AdvertiseMode advertiseMode) {
    _advertiseMode = getCorrespondingInt(advertiseMode);
    return this;
  }

  /// Sets beacon layout.
  ///
  /// This parameter is **Android only**. It's optional, the default is [ALTBEACON_LAYOUT].
  /// You can use one of the options:
  /// <ul>
  /// <li>[ALTBEACON_LAYOUT]
  /// <li>[EDDYSTONE_TLM_LAYOUT]
  /// <li>[EDDYSTONE_UID_LAYOUT]
  /// <li>[EDDYSTONE_URL_LAYOUT]
  /// <li>[URI_BEACON_LAYOUT]
  /// </ul>
  ///
  /// **For iOS**, layout will be always iBeacon.
  BeaconBroadcast setLayout(String layout) {
    _layout = layout;
    return this;
  }

  /// Sets manufacturer id.
  ///
  /// This parameter is **Android only**. It's optional, the default is Radius Network.
  /// For more information you can check the full list of [Company Identifiers](https://www.bluetooth.com/specifications/assigned-numbers/company-identifiers/).
  ///
  /// **For iOS**, the manufacturer will be always Apple.
  BeaconBroadcast setManufacturerId(int manufacturerId) {
    _manufacturerId = manufacturerId;
    return this;
  }

  /// Sets extra data.
  ///
  /// This parameter is **Android only**. If beacon layout allows it, you can
  /// add extra bytes to the data transmitted by the beacon.
  /// Value must be within a range 0-255.
  ///
  /// For more information check section
  /// [Adding extra data](https://github.com/pszklarska/beacon_broadcast#adding-extra-data)
  /// in the documentation.
  ///
  /// **For iOS**, beacon layout doesn't allow to transmit any extra data.
  ///
  /// This parameter is optional.
  BeaconBroadcast setExtraData(List<int> extraData) {
    if (extraData.any((value) => value < 0 || value > 255)) {
      throw new IllegalArgumentException(
          "Illegal arguments! Extra data values must be within a byte range 0-255");
    }
    _extraData = extraData;
    return this;
  }

  /// Starts beacon advertising.
  ///
  /// Before starting you must set  [_uuid].
  /// For the default layout, parameters [_majorId], [_minorId] are also required.
  /// Other parameters as [_identifier], [_transmissionPower], [_advertiseMode], [_layout], [_manufacturerId] are optional.
  ///
  /// For Android, beacon layout is by default set to AltBeacon (check more details here: [AltBeacon - Transmitting as a Beacon](https://altbeacon.github.io/android-beacon-library/beacon-transmitter.html)).
  /// On Android system, it's required to have Bluetooth turn on and to give app permission to location.
  ///
  /// For iOS, beacon is broadcasting as an iBeacon (check more details here: [Turning an iOS Device into an iBeacon](https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon))
  /// Note that according to the article: "After advertising your app as a beacon, your app must
  /// continue running in the foreground to broadcast the needed Bluetooth signals. If the user
  /// quits the app, the system stops advertising the device as a peripheral over Bluetooth.
  Future<void> start() async {
    if (_uuid == null || _uuid.isEmpty) {
      throw new IllegalArgumentException(
          "Illegal arguments! UUID must not be null or empty: UUID: $_uuid");
    }

    if ((_layout == null || _layout == ALTBEACON_LAYOUT) &&
        (_majorId == null || _minorId == null)) {
      throw new IllegalArgumentException(
          "Illegal arguments! MajorId and minorId must not be null or empty: "
          "majorId: $_majorId, minorId: $_minorId");
    }

    Map params = <String, dynamic>{
      "uuid": _uuid,
      "majorId": _majorId,
      "minorId": _minorId,
      "transmissionPower": _transmissionPower,
      "advertiseMode": _advertiseMode,
      "identifier": _identifier,
      "layout": _layout,
      "manufacturerId": _manufacturerId,
      "extraData": _extraData,
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
  /// * [BeaconStatus.supported] device supports transmission
  /// * [BeaconStatus.notSupportedMinSdk] Android system version on the device is lower than 21
  /// * [BeaconStatus.notSupportedBle] BLE is not supported on this device
  /// * [BeaconStatus.notSupportedCannotGetAdvertiser] device does not have a compatible chipset
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
  supported,

  /// Android system version on the device is too low (min. is 21)
  notSupportedMinSdk,

  /// Device doesn't support Bluetooth Low Energy
  notSupportedBle,

  /// Device's Bluetooth chipset or driver doesn't support transmitting
  notSupportedCannotGetAdvertiser
}

BeaconStatus fromInt(int value) {
  switch (value) {
    case 0:
      return BeaconStatus.supported;
    case 1:
      return BeaconStatus.notSupportedMinSdk;
    case 2:
      return BeaconStatus.notSupportedBle;
    default:
      return BeaconStatus.notSupportedCannotGetAdvertiser;
  }
}

enum AdvertiseMode {
  /// Consumes less energy, but larger broadcast interval
  lowPower,

  /// Balance between energy usage and broadcast interval
  balanced,

  /// Consumes more energy, but smaller broadcast interval
  lowLatency,
}

int getCorrespondingInt(AdvertiseMode advMode) {
  switch (advMode) {
    case AdvertiseMode.lowPower:
      return 0;
    case AdvertiseMode.balanced:
      return 1;
    case AdvertiseMode.lowLatency:
      return 2;
    default:
      return null;
  }
}
