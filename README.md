# Beacon Broadcast plugin for Flutter

[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter) [![Pub](https://img.shields.io/pub/v/beacon_broadcast.svg)](https://pub.dartlang.org/packages/beacon_broadcast)


A Flutter plugin for turning your device into a beacon.

### Usage

To use this plugin, add beacon_broadcast as a dependency in your pubspec.yaml 
file and import:

``` dart
import 'package:beacon_broadcast/beacon_broadcast.dart';
```

Now you can create BeaconBroadcast object and start using it:

**Important note**: For Android app, user needs to turn on Bluetooth on the 
device first.

``` dart
BeaconBroadcast beaconBroadcast = BeaconBroadcast();
```

In the simplest case, to start advertising just set your UUID, major and minor 
id and call `start()`:
``` dart
beaconBroadcast
    .setUUID('39ED98FF-2900-441A-802F-9C398FC199D2')
    .setMajorId(1)
    .setMinorId(100)
    .start();
```

You can also customize your beacon before starting:
``` dart
beaconBroadcast
    .setUUID('39ED98FF-2900-441A-802F-9C398FC199D2')
    .setMajorId(1)
    .setMinorId(100)
    .setTransmissionPower(-59) //optional
    .setIdentifier('com.example.myDeviceRegion') //iOS-only, optional
    .setLayout('s:0-1=feaa,m:2-2=10,p:3-3:-41,i:4-21v') //Android-only, optional
    .setManufacturerId(0x001D) //Android-only, optional
    .start();
```

You can check what's current state of your beacon:

``` dart
bool isAdvertising = beaconBroadcast.isAdvertising()
```

You can also listen for changes in beacon advertising state:

``` dart
beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
    // Now you know if beacon is advertising
});
```

Before advertising, you may want to check if your device supports transmitting 
as a beacon. You may do it using 
`checkTransmissionSupported()` method.


``` dart
BeaconStatus transmissionSupportStatus = await beaconBroadcast.checkTransmissionSupported();
switch (transmissionSupportStatus) {
  case BeaconStatus.SUPPORTED:
    // You're good to go, you can advertise as a beacon
    break;
  case BeaconStatus.NOT_SUPPORTED_MIN_SDK:
    // Your Android system version is too low (min. is 21)
    break;
  case BeaconStatus.NOT_SUPPORTED_BLE:
    // Your device doesn't support BLE
    break;
  case BeaconStatus.NOT_SUPPORTED_CANNOT_GET_ADVERTISER:
    // Either your chipset or driver is incompatible
    break;
}
```

If you want to stop advertising, just call `stop()`:

``` dart
beaconBroadcast.stop();
```

### Examples

Simple usage example can be found [in the example folder](example/lib/main.dart).

#### Changing beacon layouts

By default beacons layout is set according to the manufacturer 
(see section [Beacon manufacturers](#beacon-manufacturers)). You can change
that layout to imitate transmitting as a different kind of beacon.

**Note:** For iOS layout is set to iBeacon and can't be changed.

To broadcast as AltBeacon:
``` dart
beaconBroadcast
    .setUUID('39ED98FF-2900-441A-802F-9C398FC199D2')
    .setMajorId(1)
    .setMinorId(100)
    .start();
```

To broadcast as iBeacon:
``` dart
beaconBroadcast
    .setUUID('39ED98FF-2900-441A-802F-9C398FC199D2')
    .setMajorId(1)
    .setMinorId(100)
    .setLayout('m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24')
    .setManufacturerId(0x004c)
    .start();
```

#### Adding extra data

If you have your beacon layout set accordingly, you're allowed to transmit
some extra data. Depending on the layout it's usually up to 2 bytes.

For AltBeacon it's 1 byte of additional data ([source](https://altbeacon.github.io/android-beacon-library/javadoc/org/altbeacon/beacon/BeaconParser.html#setBeaconLayout-java.lang.String-)).
For iBeacon (iOS) there's no option to send extra data, as the iBeacon layout 
doesn't support it.

To add extra data using AltBeacon layout:

``` dart
beaconBroadcast
    .setUUID('39ED98FF-2900-441A-802F-9C398FC199D2')
    .setMajorId(1)
    .setMinorId(100)
    .setExtraData([123])
    .start();
```

### Beacon manufacturers
#### Android 

Android beacon will advertise as the AltBeacon manufactured by RadiusNetwork. 
You can change it with `setLayout()` and `setManufacturerId()` methods.

#### iOS
For iOS, beacon will advertise as an iBeacon (by Apple), it can't be changed. 

### Transmitting in the background

#### Android

Due to background execution limits [introduced in Android 8](https://developer.android.com/about/versions/oreo/background) 
beacons transmission in the background is limited. Based on the 
[AltBeacon documentation](https://altbeacon.github.io/android-beacon-library/beacon-transmitter.html) 
it's around 10 minutes, after that time transmission will stop. 
Current version of plugin doesn't support Foreground Services to exceed this 
limitation.

#### iOS

For iOS, application doesn't work in the background. According to the 
[CoreLocation](https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon) 
documentation:

> Important
> 
> After advertising your app as a beacon, your app must continue running in the 
> foreground to broadcast the needed Bluetooth signals. If the user quits the 
> app, the system stops advertising the device as a peripheral over Bluetooth.

### About

This plugin uses [Android Beacon Library](https://altbeacon.github.io/android-beacon-library/beacon-transmitter.html) 
for Android and [CoreLocation](https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon) 
for iOS. 

### Todo

There are still few things left to implement:
- [X] Adding option for checking for Android device support programmatically
- [X] Adding option to set layout and manufacturer for Android implementation
- [ ] Handle turning on BLE before transmitting
- [ ] Add Foreground Service to exceed background limitations on Android 8+
