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
    
    let window : UIWindow? = nil
    
    // MARK: - Variables
    var timeReportsArray: [TimeReport] = []
    
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
        
        FirebaseManager.shared.fetchTimeReports { (timeReports) in
            self.timeReportsArray = timeReports.sorted(by: { $0.date! < $1.date! })
            self.timeReportsTableView.reloadData()
            if !timeReports.isEmpty {
                self.showHideStartImage(empty: false)
                self.animateTable()
            }
        }
        
        if !timeReportsArray.isEmpty {
            showHideStartImage(empty: true)
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
    
    @IBAction func unwindToStart(segue: UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            let popVC = segue.destination
            popVC.modalPresentationStyle = .popover
            popVC.popoverPresentationController?.delegate = self
        } else if segue.identifier == "showTimeReportSegue" {
            guard let activeVC = segue.destination as? ActiveTimeReportTVC else { return }
            if let row = sender as? Int {
                activeVC.activeReport = timeReportsArray[row]
            }
        }
    }
    
    // MARK: - IBActions

    @IBAction func activeRegViewPressed(_ sender: Any) {
        performSegue(withIdentifier: "timerSegue", sender: nil)
    }
    
    @IBAction func userBtnPressed(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        let alertVC = UIAlertController(title: NSLocalizedString("Log out", comment: "Log out"), message: NSLocalizedString("Do you wish to log out?", comment: "Do you wish to log out?"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        let okAction = UIAlertAction.init(title: NSLocalizedString("Log out", comment: "Log out"), style: .default) { (action) in
            do {
                try Auth.auth().signOut()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                self.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error.localizedDescription)
            }
            
        }
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
        
    }
    
    
    
    // MARK: - Functions
    
    func showHideStartImage(empty: Bool) {
        noTimeReportsLabel.isHidden = !empty
        noTimeArrowImg.isHidden = !empty
        timeReportsTableView.isHidden = empty
//        cityImg.isHidden = !empty
    }
    
    @objc func blankReportSegue() {
        performSegue(withIdentifier: "newTimeReportSegue", sender: nil)
    }
    
    @objc func timerSegue() {
        performSegue(withIdentifier: "timerSegue", sender: nil)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "timerSegue", sender: nil)
    }
    
    func animateTable() {
        timeReportsTableView.reloadData()
        let cells = timeReportsTableView.visibleCells
        let tableViewHeight = timeReportsTableView.bounds.size.height
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        
        var delay: Double = 0
        for cell in cells {
            UIView.animate(withDuration: 0.5, delay: delay * 0.05, options: .curveEaseInOut, animations: {
                cell.transform = .identity
            }, completion: nil)
            delay += 1
        }
        
    }
    
    
    // MARK: - UITableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeReportsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "timeReportCell") as? TimeReportsCell else { return UITableViewCell() }
        if let abscent = timeReportsArray[indexPath.row].abscent {
            if abscent {
                cell.titleJobLbl.text = NSLocalizedString("Abscent this day", comment: "Abscent this day")
            } else {
                if let title = timeReportsArray[indexPath.row].title { cell.titleJobLbl.text = title }
            }
        }
        if let date = timeReportsArray[indexPath.row].date {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "YYMMdd"
            cell.dateLbl.text = dateFormat.string(from: date)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTimeReportSegue", sender: indexPath.row)
    }
    
    // MARK: - Popover Delegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

}

