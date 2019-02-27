# Beacon Broadcast plugin for Flutter

A Flutter plugin for turning your device into a beacon.

### Usage

To use this plugin, add beacon_broadcast as a dependency in your pubspec.yaml file and import:

``` dart
import 'package:beacon_broadcast/beacon_broadcast.dart';
```

Now you can create BeaconBroadcast object and start using it:

``` dart
BeaconBroadcast beaconBroadcast = BeaconBroadcast();
```

To start advertising, just set parameters and call `start()`
``` dart
beaconBroadcast
    .setUUID('39ED98FF-2900-441A-802F-9C398FC199D2')
    .setMajorId(1)
    .setMinorId(100)
    .setTransmissionPower(-59) //optional
    .setIdentifier("com.example.myDeviceRegion") //iOS-only, optional
    .start();
```

You can check what's current state of your beacon:

``` dart
var isAdvertising = beaconBroadcast.isAdvertising()
```

You can also register for changes in beacon advertising state:

``` dart
beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
    // Now you know if beacon is advertising
});
```

If you want to stop advertising, just call `stop()`:

``` dart
beaconBroadcast.stop();
```

#### Android

For Android app, user needs to turn on Bluetooth first and grant location permission. 

#### iOS

For iOS, it's worth to mention that application needs to work in foreground. According to the 
[CoreLocation](https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon) 
documentation:

> Important
> 
> After advertising your app as a beacon, your app must continue running in the foreground to broadcast the needed 
> Bluetooth signals. If the user quits the app, the system stops advertising the device as a peripheral over Bluetooth.

### About

This plugin uses [Android Beacon Library](https://altbeacon.github.io/android-beacon-library/beacon-transmitter.html) 
for Android and [CoreLocation](https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon) 
for iOS. 

### Todo

There are still few things left to implement:
- [ ] Adding option to set layout and manufacturer for Android implementation
- [ ] Handle turning on BLE and granting location permission on Android
- [ ] Adding option for checking for Android device support programmatically