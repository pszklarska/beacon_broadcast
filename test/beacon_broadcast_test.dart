import 'dart:async';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

void main() {
  BeaconBroadcast beaconBroadcast;

  setUp(() {
    beaconBroadcast = BeaconBroadcast();

    const MethodChannel methodChannel = MethodChannel(
      'pl.pszklarska.beaconbroadcast/beacon_state',
    );

    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'start' || methodCall.method == 'stop') {
        return Future<void>.value();
      } else if (methodCall.method == 'isAdvertising') {
        return Future<bool>.value(true);
      }
      return null;
    });
  });

  group('starting beacon advertising', () {
    test('passing all the data starts normally', () async {
      expect(
          () => beaconBroadcast
              .setUUID("uuid")
              .setMajorId(1)
              .setMinorId(1)
              .setTransmissionPower(-59)
              .setIdentifier("identifier")
              .start(),
          returnsNormally);
    });

    test('not passing uuid throws exception', () async {
      expect(
          () => beaconBroadcast
              .setMajorId(1)
              .setMinorId(1)
              .setTransmissionPower(-59)
              .setIdentifier("identifier")
              .start(),
          throwsA(const TypeMatcher<IllegalArgumentException>()));
    });

    test('not passing major id throws exception', () async {
      expect(
          () => beaconBroadcast
              .setUUID("uuid")
              .setMinorId(1)
              .setTransmissionPower(-59)
              .setIdentifier("identifier")
              .start(),
          throwsA(const TypeMatcher<IllegalArgumentException>()));
    });

    test('not passing minor id throws exception', () async {
      expect(
          () => beaconBroadcast
              .setUUID("uuid")
              .setMajorId(1)
              .setTransmissionPower(-59)
              .setIdentifier("identifier")
              .start(),
          throwsA(const TypeMatcher<IllegalArgumentException>()));
    });

    test('not passing identifier and tansmission power starts normally', () async {
      expect(() => beaconBroadcast.setUUID("uuid").setMajorId(1).setMinorId(1).start(),
          returnsNormally);
    });
  });

  test('checking if beacon is advertising returns true', () async {
    expect(await beaconBroadcast.isAdvertising(), isTrue);
  });
}
