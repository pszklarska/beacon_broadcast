import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';

void main() {
  const MethodChannel channel = MethodChannel('beacon_broadcast');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

//  test('getPlatformVersion', () async {
//    expect(await BeaconBroadcast.platformVersion, '42');
//  });
}
