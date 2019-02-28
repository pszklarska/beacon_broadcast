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
        switch (call.method) {
        case "start":
            startBeacon(call, result)
        case "stop":
            stopBeacon(call, result)
        case "isAdvertising":
            isAdvertising(call, result)
        case "isTransmissionSupported":
            isTransmissionSupported(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startBeacon(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        var map = call.arguments as? Dictionary<String, Any>
        let beaconData = BeaconData(
            uuid: map?["uuid"] as! String,
            majorId: map?["majorId"] as! NSNumber,
            minorId: map?["minorId"] as! NSNumber,
            transmissionPower: map?["transmissionPower"] as? NSNumber,
            identifier: map?["identifier"] as! String
        )
        beacon.start(beaconData: beaconData)
        result(nil)
    }
    
    private func stopBeacon(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        beacon.stop()
        result(nil)
    }
    
    private func isAdvertising(_ call: FlutterMethodCall,
                               _ result: @escaping FlutterResult) {
        result(beacon.isAdvertising())
    }
    
    private func isTransmissionSupported(_ call: FlutterMethodCall,
                               _ result: @escaping FlutterResult) {
        result(0)
    }
}
