//
//  BluetoothServices.swift
//  MapBoxDemo
//
//  Created by imac-3282 on 2023/12/25.
//

import Foundation
import CoreBluetooth

class BluetoothServices: NSObject {
    
    static let shared = BluetoothServices()
    
    var central: CBCentralManager?
    var peripheral: CBPeripheralManager?
    
    var blePeripherals: [CBPeripheral] = []
    
    var serial1 = PeripheralInformation()
    var serial2 = PeripheralInformation()
    
    weak var delegate: BluetoothServicesDelegate?
    
    private override init() {
        super.init()
        
        let quene = DispatchQueue.global()
        central = CBCentralManager(delegate: self, queue: quene)
    }
    
    func startScan() {
        central?.scanForPeripherals(withServices: nil)
    }
    
    func stopScan() {
        central?.stopScan()
    }
    
    func connectPeripheral(peripheral: CBPeripheral) {
        central?.connect(peripheral)
    }
    
    func disconnectPeripheral(peripheral: CBPeripheral) {
        central?.cancelPeripheralConnection(peripheral)
    }
}

extension BluetoothServices: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
        @unknown default:
            print("藍芽裝置未知狀態")
        }
        
        startScan()
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        for blePeripheral in blePeripherals {
            if peripheral.name == blePeripheral.name {
                return
            }
        }
        
        if let name = peripheral.name {
            blePeripherals.append(peripheral)
            print(name)
        }
        
        if peripheral.name == "TaiRa_BLE Serial_1" {
            serial1.serial = peripheral
        }
        
        if peripheral.name == "TaiRa_BLE Serial_2" {
            serial2.serial = peripheral
        }
        
        delegate?.getPeripheral(peripherals: blePeripherals)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print(serial1.serial?.name)
        print(serial2.serial?.name)
    }
    
    func writeValue(peripheral: CBPeripheral,
                    characteristic: CBCharacteristic,
                    type: CBCharacteristicWriteType,
                    data: Data) {
        peripheral.writeValue(data, for: characteristic, type: type)
    }
}

extension BluetoothServices: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        switch peripheral {
        case serial1.serial:
            if let services = peripheral.services {
                for service in services {
                    if service.uuid.isEqual(CBUUID(string: "0003CDD0-0000-1000-8000-00805F9B0131")) {
                        serial1.serialService = service
                        peripheral.discoverCharacteristics(nil, for: service)
                    }
                }
            }
        case serial2.serial:
            if let services = peripheral.services {
                for service in services {
                    if service.uuid.isEqual(CBUUID(string: "0003CDD0-0000-1000-8000-00805F9B0131")) {
                        serial2.serialService = service
                        peripheral.discoverCharacteristics(nil, for: service)
                    }
                }
            }
        default:
            break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        switch peripheral {
        case serial1.serial:
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.uuid.isEqual(CBUUID(string: "0003CDD1-0000-1000-8000-00805F9B0131")) {
                        serial1.serialReadCharacteristic = characteristic
                        peripheral.readValue(for: characteristic)
                        peripheral.setNotifyValue(true, for: characteristic)
                    } else if characteristic.uuid.isEqual(CBUUID(string: "0003CDD2-0000-1000-8000-00805F9B0131")) {
                        serial1.serialWriteCharacteristic = characteristic
                    }
                }
            }
            print(serial1)
        case serial2.serial:
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.uuid.isEqual(CBUUID(string: "0003CDD1-0000-1000-8000-00805F9B0131")) {
                        serial2.serialReadCharacteristic = characteristic
                        peripheral.readValue(for: characteristic)
                        peripheral.setNotifyValue(true, for: characteristic)
                    } else if characteristic.uuid.isEqual(CBUUID(string: "0003CDD2-0000-1000-8000-00805F9B0131")) {
                        serial2.serialWriteCharacteristic = characteristic
                    }
                }
            }
            print(serial2)
        default:
            break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, 
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        var characteristicASCIIValue = String()
        
        switch peripheral {
        case serial1.serial:
            guard characteristic == serial1.serialReadCharacteristic,
                  let characteristicValue = characteristic.value,
                  let ASCIIstring = String(data: characteristicValue,
                                           encoding: String.Encoding.ascii) else {
                return
            }
            characteristicASCIIValue = ASCIIstring
            print(characteristicASCIIValue)
            delegate?.getMessage(message: characteristicASCIIValue)
        case serial2.serial:
            guard characteristic == serial2.serialReadCharacteristic,
                  let characteristicValue = characteristic.value,
                  let ASCIIstring = String(data: characteristicValue,
                                           encoding: String.Encoding.ascii) else {
                return
            }
            characteristicASCIIValue = ASCIIstring
            print(characteristicASCIIValue)
            delegate?.getMessage(message: characteristicASCIIValue)
        default:
            break
        }
    }
}

protocol BluetoothServicesDelegate: NSObjectProtocol {
    func getPeripheral(peripherals: [CBPeripheral])
    
    func getMessage(message: String)
}
