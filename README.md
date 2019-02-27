# Beacon Broadcast plugin for Flutter

A Flutter plugin for turning your device into a beacon.

### Example

To use this plugin, add beacon_broadcast as a dependency in your pubspec.yaml file:

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