//
//  GISTrackerViewController.swift
//  MapBoxDemo
//
//  Created by imac-3282 on 2024/1/17.
//

import UIKit
import CoreBluetooth

class GISTrackerViewController: UIViewController {

    @IBOutlet weak var peripheralTableView: UITableView!
    
    let bluetooth = BluetoothServices.shared
    
    var peripherals: [CBPeripheral] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        overrideUserInterfaceStyle = .dark
        
        setupBluetooth()
        setupTableView()
    }
    
    func setupBluetooth() {
        bluetooth.delegate = self
        bluetooth.startScan()
    }
    
    private func setupTableView() {
        peripheralTableView.delegate = self
        peripheralTableView.dataSource = self
        peripheralTableView.register(UINib(nibName: "PeripheralTableViewCell", bundle: nil),
                                     forCellReuseIdentifier: PeripheralTableViewCell.identifier)
    }
}

extension GISTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PeripheralTableViewCell.identifier,
                                                       for: indexPath) as? PeripheralTableViewCell else {
            fatalError("PeripheralTableViewCell Can't Loaded！")
        }
        
        cell.nameLabel.text = peripherals[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = MessageViewController()
        nextVC.peripheral = peripherals[indexPath.row]
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension GISTrackerViewController: BluetoothServicesDelegate {
    func getMessage(message: String) {
    }
    
    func getPeripheral(peripherals: [CBPeripheral]) {
        self.peripherals = peripherals
        
        DispatchQueue.main.async {
            self.peripheralTableView.reloadData()
        }
    }
}
