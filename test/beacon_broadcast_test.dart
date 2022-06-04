import 'dart:async';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel methodChannel = MethodChannel(
    'pl.pszklarska.beaconbroadcast/beacon_state',
  );

  void onStartMethodReturn(Future value) {
    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'start') {
        return value;
      }
    });
  }

  void onStopMethodReturn(Future value) {
    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'stop') {
        return value;
      }
    });
  }

  void onIsAdvertisingMethodReturn(Future value) {
    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'isAdvertising') {
        return value;
      }
    });
  }

  void onIsTransmissionSupportedMethodReturn(Future value) {
    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'isTransmissionSupported') {
        return value;
      }
    });
  }

  group('starting beacon advertising', () {
    test('when all data is set returns normally', () async {
      onStartMethodReturn(Future.value());

      expect(
          () => BeaconBroadcast()
              .setUUID("uuid")
              .setMajorId(1)
              .setMinorId(1)
              .setTransmissionPower(-59)
              .setAdvertiseMode(AdvertiseMode.lowLatency)
              .setManufacturerId(0)
              .setExtraData([100])
              .setIdentifier("identifier")
              .start(),
          returnsNormally);
    });

    test('when uuid is not set throws exception', () async {
      onStartMethodReturn(Future.value());
      expect(
          () => BeaconBroadcast()
              .setMajorId(1)
              .setMinorId(1)
              .setTransmissionPower(-59)
              .setIdentifier("identifier")
              .start(),
          throwsA(isA<IllegalArgumentException>()));
    });

    test('when major id is not set throws exception', () async {
      onStartMethodReturn(Future.value());
      expect(
          () => BeaconBroadcast()
              .setUUID("uuid")
              .setMinorId(1)
              .setTransmissionPower(-59)
              .setIdentifier("identifier")
              .start(),
          throwsA(isA<IllegalArgumentException>()));
    });

    test('when minor id is not set throws exception', () async {
      onStartMethodReturn(Future.value());
      expect(
          () => BeaconBroadcast()
              .setUUID("uuid")
              .setMajorId(1)
              .setTransmissionPower(-59)
              .setIdentifier("identifier")
              .start(),
          throwsA(isA<IllegalArgumentException>()));
    });

    test('when identifier and transmission power are not set starts normally',
        () async {
      onStartMethodReturn(Future.value());
      expect(
          () => BeaconBroadcast()
              .setUUID("uuid")
              .setMajorId(1)
              .setMinorId(1)
              .start(),
          returnsNormally);
    });

    test('when extra data contains integer out of range throws exception',
        () async {
      onStartMethodReturn(Future.value());
      expect(
          () => BeaconBroadcast().setUUID("uuid").setExtraData([270]).start(),
          throwsA(isA<IllegalArgumentException>()));
    });

    group('when custom layout is set', () {
      test('and minor id is not set returns normally', () async {
        onStartMethodReturn(Future.value());
        expect(
            () => BeaconBroadcast()
                .setUUID("uuid")
                .setMajorId(1)
                .setTransmissionPower(-59)
                .setIdentifier("identifier")
                .setLayout("layout")
                .start(),
            returnsNormally);
      });

      test('and major id is not set returns normally', () async {
        onStartMethodReturn(Future.value());
        expect(
            () => BeaconBroadcast()
                .setUUID("uuid")
                .setMinorId(1)
                .setTransmissionPower(-59)
                .setIdentifier("identifier")
                .setLayout("layout")
                .start(),
            returnsNormally);
      });

      test('and UUID is not set throws exception', () async {
        onStartMethodReturn(Future.value());
        expect(
            () => BeaconBroadcast()
                .setMinorId(1)
                .setTransmissionPower(-59)
                .setIdentifier("identifier")
                .setLayout("layout")
                .start(),
            throwsA(isA<IllegalArgumentException>()));
      });
    });
  });

  group('checking if transmission is supported', () {
    test('when device returns 0 return BeaconStatus.supported', () async {
      onIsTransmissionSupportedMethodReturn(Future.value(0));
      expect(await BeaconBroadcast().checkTransmissionSupported(),
          BeaconStatus.supported);
    });

    test('when device returns 1 return BeaconStatus.notSupportedMinSdk',
        () async {
      onIsTransmissionSupportedMethodReturn(Future.value(1));
      expect(await BeaconBroadcast().checkTransmissionSupported(),
          BeaconStatus.notSupportedMinSdk);
    });

    test('when device returns 2 return BeaconStatus.notSupportedBle', () async {
      onIsTransmissionSupportedMethodReturn(Future.value(2));
      expect(await BeaconBroadcast().checkTransmissionSupported(),
          BeaconStatus.notSupportedBle);
    });

    test(
        'when device returns other value return BeaconStatus.notSupportedCannotGetAdvertiser',
        () async {
      onIsTransmissionSupportedMethodReturn(Future.value(3));
      expect(await BeaconBroadcast().checkTransmissionSupported(),
          BeaconStatus.notSupportedCannotGetAdvertiser);
    });
  });

  test('beacon is advertising returns true', () async {
    onIsAdvertisingMethodReturn(Future.value(true));
    expect(await BeaconBroadcast().isAdvertising(), isTrue);
  });

  test('beacon stops returns normally', () async {
    onStopMethodReturn(Future.value());
    expect(() => BeaconBroadcast().stop(), returnsNormally);
  });
}
