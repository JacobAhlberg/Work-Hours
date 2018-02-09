//
//  ViewController.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-07.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit

class TimeReportsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var noTimeReportsLabel: UILabel!
    @IBOutlet weak var timeReportsTableView: UITableView!
    
    
    // MARK: - Variables
    var timeReportsArray: [String] = []
    
    
    // MARK: - Application runtime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(segue), name: NSNotification.Name(rawValue: "NewTimeReport"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !timeReportsArray.isEmpty {
            noTimeReportsLabel.isHidden = true
            timeReportsTableView.isHidden = false
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            let popVC = segue.destination
            popVC.modalPresentationStyle = .popover
            popVC.popoverPresentationController?.delegate = self
        }
    }
    
    @IBAction func unwindToTimeReports(segue: UIStoryboardSegue) {
//        if segue.identifier == "createNewTimeReport" {
//            performSegue(withIdentifier: "newTimeReportSegue", sender: nil)
//        }
    }
    
    // MARK: - IBActions
    
    @IBAction func addBtnPressed(_ sender: Any) {
//        performSegue(withIdentifier: "newTimeReportSegue", sender: nil)
    }
    
    // MARK: - Functions
    
    @objc func segue() {
        performSegue(withIdentifier: "newTimeReportSegue", sender: nil)
    }
    
    // MARK: - UITableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeReportsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: - Popover Delegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    


}

