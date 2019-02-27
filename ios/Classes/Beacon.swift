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
        let major : CLBeaconMajorValue = CLBeaconMajorValue(truncating: beaconData.majorId)
        let minor : CLBeaconMinorValue = CLBeaconMinorValue(truncating: beaconData.minorId)
        let beaconID = beaconData.identifier
        
        let region = CLBeaconRegion(proximityUUID: proximityUUID!,
                                    major: major, minor: minor, identifier: beaconID)
        
        if (peripheralManager == nil) {
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }
        
        beaconPeripheralData = region.peripheralData(withMeasuredPower: beaconData.transmissionPower)
        shouldStartAdvertise = true
    }
    
    func stop() {
        if (peripheralManager != nil) {
            print("stop invoked")
            peripheralManager.stopAdvertising()
            onAdvertisingStateChanged!(false)
        }
    }
    
    func isAdvertising() -> Bool {
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
    var majorId: NSNumber
    var minorId: NSNumber
    var transmissionPower: NSNumber?
    var identifier: String
    
    init(uuid: String, majorId:NSNumber, minorId: NSNumber, transmissionPower: NSNumber?, identifier: String) {
        self.uuid = uuid
        self.majorId = majorId
        self.minorId = minorId
        self.transmissionPower = transmissionPower
        self.identifier = identifier
    }
}
