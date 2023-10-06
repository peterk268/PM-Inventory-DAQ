//
//  DAQViewModel.swift
//  PM Inventory
//
//  Created by Peter Khouly on 10/5/23.
//

import Foundation
import CoreBluetooth

public let daqCharacteristicUUID = CBUUID.init(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
public let daqServiceUUID = CBUUID.init(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")

class DAQViewModel: NSObject, ObservableObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    @Published var isConnected = false
    @Published var recievedAccelData: AccelerometerData?
    
    private var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic?
        
    func initializeCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        switch central.state {
        case .unknown:
            print("unknown")
            break
        case .resetting:
            print("Resetting")
            break
        case .unsupported:
            print("Unsupported")
            break
        case .unauthorized:
            print("Unathorized")
            break
        case .poweredOff:
            print("Central is not powered on")
            break
        case .poweredOn:
            print("Central scanning for", daqServiceUUID);
            centralManager.scanForPeripherals(withServices: nil/*[daqServiceUUID]*/,
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            break
        @unknown default:
            print("default")
            break
        }
        if central.state != .poweredOn {
            
        } else {
        }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check if the discovered peripheral has a name
        if let peripheralName = peripheral.name {
            if peripheralName == "PM-DAQ" {
                // You've found your peripheral by name
                centralManager.stopScan()
                
                // Copy the peripheral instance
                self.peripheral = peripheral
                self.peripheral.delegate = self
                
                // Connect!
                self.centralManager.connect(self.peripheral, options: nil)
            }
        }
//        // We've found it so stop scan
//        self.centralManager.stopScan()
//
//        // Copy the peripheral instance
//        self.peripheral = peripheral
//        self.peripheral.delegate = self
//
//        // Connect!
//        self.centralManager.connect(self.peripheral, options: nil)
        
    }
    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to DAQ")
            peripheral.discoverServices([daqServiceUUID])
        }
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == daqServiceUUID {
                    print("daq service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([daqCharacteristicUUID], for: service)
                    return
                }
            }
        }
    }

    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == daqCharacteristicUUID {
                    print("DAQ characteristic found")
                    self.characteristic = characteristic
                    self.isConnected = true
                }
            }
        }
    }
    
    func readValueFromChar(withCharacteristic characteristic: CBCharacteristic) async {
        // Check if it has the read property
        if characteristic.properties.contains(.read) && peripheral != nil {
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            if let stringValue = String(data: data, encoding: .utf8) {
                guard let accelData = try? JSONDecoder().decode(AccelerometerData.self, from: data)
                else { print("decoding error", stringValue); return }
                
                self.recievedAccelData = accelData
                
                print("Received string value: \(stringValue)")
            }
        }
    }

//    func getAccelData() async {
//        if let characteristic, let data = await self.readValueFromChar(withCharacteristic: characteristic) {
//            guard let stringFromData = String(data: data, encoding: .utf8) else { return }
//            var values = [UInt8](count: data.count, repeatedValue: 0)
//            data.getBytes(&values, length: data.count)
//        }
//    }

    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        // Start scanning again
        print("Central scanning for", daqServiceUUID);
        centralManager.scanForPeripherals(withServices: [daqServiceUUID],
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    
}

struct AccelerometerData: Codable, Equatable {
    let x: Int
    let y: Int
    let z: Int
}
