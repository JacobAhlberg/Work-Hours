//
//  CustomersVC.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit

class CustomersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var customerTableView: UITableView!
    
    
    // MARK: - Class variables
    var customers: [String] = []
    
    
    // MARK: - Application runtime
    override func viewDidLoad() {
        super.viewDidLoad()
        print(customers.count)
        FirebaseManager.instance.fetchCustomers { (fetchedCustomers) in
            if let fetchedCustomers = fetchedCustomers {
                self.customers = fetchedCustomers
                print(self.customers.count)
                self.customerTableView.reloadData()
            } else {
                self.showAlert(messageForUser: NSLocalizedString("Something went wrong, please reload the page", comment: "Something went wrong, please reload the page"))
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newTimeReportSegue" {
            guard let newTimeReportVC = segue.destination as? NewTimeReportTVC else { return }
            if let row = sender as? Int {
                newTimeReportVC.customerLbl.text = customers[row]
            }
        }
    }
    
    // MARK: - Functions
    
    
    // MARK: - TableView Delegate & Datasourcwe
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customerCell") as? CustomerCell else { return UITableViewCell() }
        cell.customerName.text = customers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "newTimeReportSegue", sender: indexPath.row)
    }

}
