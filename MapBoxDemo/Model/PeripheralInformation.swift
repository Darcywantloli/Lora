//
//  PeripheralModel.swift
//  MapBoxDemo
//
//  Created by imac-3282 on 2024/1/11.
//

import Foundation
import CoreBluetooth

struct PeripheralInformation {
    
    var serial: CBPeripheral?
    
    var serialService: CBService?
    
    var serialReadCharacteristic: CBCharacteristic?
    
    var serialWriteCharacteristic: CBCharacteristic?
    
}

struct PeripheralMessage {
    
    var message: String?
    
    var getOrSend: Bool?
    
}
