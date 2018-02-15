//
//  CustomerCell.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {

    @IBOutlet weak var customerName: UILabel!
    
    @IBAction func addCustomerBtnPressed() {
        if let name = customerName.text {
            print(name)
        }
    }

}
