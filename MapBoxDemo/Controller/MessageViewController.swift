//
//  MessageViewController.swift
//  MapBoxDemo
//
//  Created by imac-3282 on 2024/1/18.
//

import UIKit
import CoreBluetooth

class MessageViewController: UIViewController {
    
    let bluetooth = BluetoothServices.shared
    var peripheral: CBPeripheral?

    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var messageArray: [PeripheralMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        setupTableView()
        setupBluetooth()
    }
    
    private func setupBluetooth() {
        bluetooth.delegate = self
        bluetooth.connectPeripheral(peripheral: peripheral!)
    }
    
    private func setupTableView() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: MessageTableViewCell.identifier)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        guard let text = messageTextField.text else { return }
        
        if text == "<.GPS" {
            
        } else {
            
        }
        
        let data = text.data(using: .ascii)
        
        switch peripheral {
        case bluetooth.serial1.serial:
            bluetooth.writeValue(peripheral: peripheral!,
                                 characteristic: bluetooth.serial1.serialWriteCharacteristic!,
                                 type: .withoutResponse,
                                 data: data!)
        case bluetooth.serial2.serial:
            bluetooth.writeValue(peripheral: peripheral!,
                                 characteristic: bluetooth.serial2.serialWriteCharacteristic!,
                                 type: .withoutResponse,
                                 data: data!)
        default:
            break
        }
        
        var message = PeripheralMessage()
        message.getOrSend = true
        message.message = messageTextField.text
        
        messageArray.append(message)
        messageTableView.reloadData()
    }
}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier,
                                                 for: indexPath) as! MessageTableViewCell
        
        cell.messageLabel.text = messageArray[indexPath.row].message
        
        if messageArray[indexPath.row].getOrSend! {
            cell.backgroundColor = .yellow
        } else {
            cell.backgroundColor = .green
        }
        
        return cell
    }
}

extension MessageViewController: BluetoothServicesDelegate {
    func getPeripheral(peripherals: [CBPeripheral]) {
    }
    
    func getMessage(message: String) {
        DispatchQueue.main.async {
            var peripheralMessage = PeripheralMessage()
            
            peripheralMessage.message = message
            peripheralMessage.getOrSend = true
            
            self.messageArray.append(peripheralMessage)
        }
    }
}
