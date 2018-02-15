//
//  Extensions.swift
//  Work Hours
//
//  Created by Giovanni Palusa on 2018-02-14.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(messageForUser message: String) {
        let alertVC = UIAlertController(title: NSLocalizedString("Information", comment: "Information"), message: NSLocalizedString(message, comment: message), preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
}
