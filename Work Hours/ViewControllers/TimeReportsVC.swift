//
//  ViewController.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-07.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit
import Firebase

class TimeReportsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var noTimeReportsLabel: UILabel!
    @IBOutlet weak var noTimeArrowImg: UIImageView!
    @IBOutlet weak var timeReportsTableView: UITableView!
    @IBOutlet weak var activeRegView: UIView!
    @IBOutlet weak var cityImg: UIImageView!
    
    
    // MARK: - Variables
    var timeReportsArray: [String] = []
    
    var user = Auth.auth().currentUser
    
    
    // MARK: - Application runtime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(blankReportSegue), name: NSNotification.Name(rawValue: "NewTimeReport"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(timerSegue), name: NSNotification.Name(rawValue: "NewTimerStart"), object: nil)
        
        if let defaultsDate = UserDefaults.standard.object(forKey: "timerStartValue") {
            let startTime = defaultsDate as! Date
            if startTime < Date() {
                performSegue(withIdentifier: "timerSegue", sender: nil)
            }
        }
        
        // Ask for push permission
        PushManager.shared.requestAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !timeReportsArray.isEmpty {
            noTimeReportsLabel.isHidden = true
            noTimeArrowImg.isHidden = true
            timeReportsTableView.isHidden = false
            cityImg.isHidden = true
        }
        
        if let defaultsDate = UserDefaults.standard.object(forKey: "timerStartValue") {
            let startTime = defaultsDate as! Date
            if startTime < Date() {
                activeRegView.isHidden = false
                pulsate(view: activeRegView)
                noTimeArrowImg.isHidden = true
            }
        } else {
            activeRegView.isHidden = true
            if timeReportsArray.isEmpty {
                noTimeArrowImg.isHidden = false
            }
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
    
    // MARK: - IBActions

    @IBAction func activeRegViewPressed(_ sender: Any) {
        performSegue(withIdentifier: "timerSegue", sender: nil)
    }
    
    
    // MARK: - Functions
    
    @objc func blankReportSegue() {
        performSegue(withIdentifier: "newTimeReportSegue", sender: nil)
    }
    
    @objc func timerSegue() {
        performSegue(withIdentifier: "timerSegue", sender: nil)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "timerSegue", sender: nil)
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

