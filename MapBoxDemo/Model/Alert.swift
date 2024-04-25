//
//  Alert.swift
//  MapBoxDemo
//
//  Created by imac-3282 on 2024/2/22.
//

import Foundation
import UIKit

class Alert {
    func showAlertWithTextField(title: String,
                                message: String,
                                confirmTitle: String,
                                setTextField: @escaping (UITextField) -> Void) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            alertController.addTextField { textField in
                setTextField(textField)
            }
            
            let confirmAction = UIAlertAction(title: confirmTitle, style: .default)
        }
    }
}
