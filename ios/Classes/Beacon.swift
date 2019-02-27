//
//  Beacon.swift
//
//  Created by Paulina Szklarska on 23/01/2019.
//  Copyright © 2019 Paulina Szklarska. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

class Beacon : NSObject, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager!
    var beaconPeripheralData: NSDictionary!
    var onAdvertisingStateChanged: ((Bool) -> Void)?
    
    var shouldStartAdvertise: Bool = false
    
    func start(beaconData: BeaconData) {
        print("starting with id... \(beaconData.uuid)")
        
        let proximityUUID = UUID(uuidString: beaconData.uuid)
        let major : CLBeaconMajorValue = 100
        let minor : CLBeaconMinorValue = 1
        let beaconID = "com.example.myDeviceRegion"
        
        let region = CLBeaconRegion(proximityUUID: proximityUUID!,
                                    major: major, minor: minor, identifier: beaconID)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        beaconPeripheralData = region.peripheralData(withMeasuredPower: nil)
        shouldStartAdvertise = true
    }
    
    func stop() {
        if (peripheralManager != nil) {
            print("stop invoked")
            peripheralManager.stopAdvertising()
            onAdvertisingStateChanged!(false)
        }
    }
    
    func isStarted() -> Bool {
        if (peripheralManager == nil) {
            return false
        }
        return peripheralManager.isAdvertising
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        onAdvertisingStateChanged!(peripheral.isAdvertising)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if (peripheral.state == .poweredOn && shouldStartAdvertise) {
            print("start invoked")
            peripheralManager.startAdvertising(((beaconPeripheralData as NSDictionary) as! [String : Any]))
            shouldStartAdvertise = false
        }
    }
    
}

class BeaconData {
    var uuid: String
    
    init(uuid: String) {
        self.uuid = uuid
    }
}
