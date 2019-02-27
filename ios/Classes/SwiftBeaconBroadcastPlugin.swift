import Flutter
import UIKit


public class SwiftBeaconBroadcastPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private var beacon = Beacon()
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftBeaconBroadcastPlugin()
        
        let channel = FlutterMethodChannel(name: "pl.pszklarska.beaconbroadcast/beacon_state", binaryMessenger: registrar.messenger())
        
        let beaconEventChannel = FlutterEventChannel(name: "pl.pszklarska.beaconbroadcast/beacon_events", binaryMessenger: registrar.messenger())
        beaconEventChannel.setStreamHandler(instance)
        instance.registerBeaconListener()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func onListen(withArguments arguments: Any?,
                  eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }
    
    func registerBeaconListener() {
        beacon.onAdvertisingStateChanged = {isAdvertising in
            if (self.eventSink != nil) {
                self.eventSink!(isAdvertising)
            }
        }
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "start") {
            beacon.start()
            result(nil)
        } else if (call.method == "stop") {
            beacon.stop()
            result(nil)
        } else if (call.method == "isStarted") {
            result(beacon.isStarted())
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
