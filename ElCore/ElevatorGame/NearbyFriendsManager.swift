//
//  NearbyFriendsManager.swift
//  ElCore
//
//  Created by Peter Larson on 5/1/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import CoreBluetooth

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public protocol NearbyFriendsManagerDelegate {
    func discovered(advertisement data: [String:Any])
}

open class NearbyFriendsManager: NSObject {
    
    public var delegate: NearbyFriendsManagerDelegate? = nil
    
    private let saves = UserDefaults()
    
    private static let user_id = "user_id"
    
    private static let friends = "friends"
    
    public func meet(friend id: UUID) {
        var array = saves.stringArray(forKey: NearbyFriendsManager.friends) ?? []
        array.append(id.uuidString)
        saves.set(array, forKey: NearbyFriendsManager.friends)
    }
    
    public func hasMet(friend id: UUID) -> Bool {
        if let array = saves.stringArray(forKey: NearbyFriendsManager.friends), array.contains(id.uuidString) {
            return true
        } else {
            return false
        }
    }
    
    fileprivate var userID: UUID {
        get {
            guard let string = saves.string(forKey: NearbyFriendsManager.user_id), let id = UUID(uuidString: string) else {
                let newID = UUID()
                saves.set(newID.uuidString, forKey: NearbyFriendsManager.user_id)
                return newID
            }
            return id
        }
    }
    
    public var name: String {
        var string = String()
        
        #if canImport(UIKit)
            string+="\(UIDevice.current.name)"
        #elseif canImport(AppKit)
            string+="OSX-TEST"
        #endif
        
        string.append(" \(userID.uuidString)")
        
        return string
    }
    
    override public init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    fileprivate var centralManager: CBCentralManager!
    
    fileprivate var peripheralManager: CBPeripheralManager!
    
    fileprivate static let elevator_bluetooth_app_id = CBUUID(string: "B8EB0923-E7AA-4AE3-A378-42F4E727DABA")
    
    fileprivate func startScanning(_ central: CBCentralManager) {
        centralManager.scanForPeripherals(withServices: [NearbyFriendsManager.elevator_bluetooth_app_id], options: nil)
    }
}

extension NearbyFriendsManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        guard central.state == .poweredOn else {
            return
        }
        
        self.startScanning(central)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        central.connect(peripheral, options: nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
}

extension NearbyFriendsManager: CBPeripheralManagerDelegate {
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
                
        guard peripheral.state == .poweredOn else {
            return
        }
        
        let data: [String : Any] = [
            CBAdvertisementDataServiceUUIDsKey: [NearbyFriendsManager.elevator_bluetooth_app_id],
            CBAdvertisementDataLocalNameKey: name
        ]
        
        peripheral.startAdvertising(data)
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
    }
    
    
}

extension NearbyFriendsManager: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
}
