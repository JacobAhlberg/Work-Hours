//
//  timerVC.swift
//  Work Hours
//
//  Created by Giovanni Palusa on 2018-02-10.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit

class TimerVC: UIViewController {
    
    // MARK: IB outlets
    @IBOutlet weak var activeLogView: UIView!
    @IBOutlet weak var startTimerBtn: OutlinedButton!
    @IBOutlet weak var breakBtn: OutlinedButton!
    
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var registrationLbl: UILabel!
    
    // MARK: - Class variables
    var isActive = false
    var pushActive = false
    var startTime = Date()
    var finishedTime = Date()
    var breakIsActive: Bool = false
    var startBreakTime: Date = Date()
    var totalBreakTime : Double = 0
    
    let dateFormatter = DateFormatter()
    
    // MARK: Strings that are being used multiple times
    let stopTimerString = NSLocalizedString("STOP TIMER", comment: "STOP TIMER")
    let startTimerString = NSLocalizedString("START TIMER", comment: "START TIMER")
    let stopBreakString = NSLocalizedString("STOP BREAK", comment: "STOP BREAK")
    let startBreakString = NSLocalizedString("START BREAK", comment: "STOP BREAK")
    let registrationActiveString = NSLocalizedString("Registration is active", comment: "Registration is active")
    let breakActiveString = NSLocalizedString("Break is active", comment: "Break is active")
    let startedString = NSLocalizedString("Started : ", comment: "Started : ")
    
    // MARK: User Defaults strings
    let userDefTimer = "timerStartValue"
    let userDefBreak = "totalBreakTime"
    let userDefBreakBool = "breakBool"
    let userDefStartBreak = "breakStart"
    let userDefPushActive = "pushActive"
    
    // MARK: Application runtime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activeLogView.isHidden = true
        breakBtn.isEnabled = false
        breakBtn.alpha = 0.5
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // Get user defaults
        totalBreakTime = UserDefaults.standard.double(forKey: userDefBreak)
        breakIsActive = UserDefaults.standard.bool(forKey: userDefBreakBool)
        pushActive = UserDefaults.standard.bool(forKey: userDefPushActive)
        
        if let defaultsStartBreakTime = UserDefaults.standard.object(forKey: userDefStartBreak) {
            startBreakTime = defaultsStartBreakTime as! Date
        }
        
        if let defaultsDate = UserDefaults.standard.object(forKey: userDefTimer) {
            startTime = defaultsDate as! Date
            if startTime < Date() {
                isActive = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if isActive {
            if breakIsActive {
                continueTimer(isBreak: true)
            } else {
                continueTimer(isBreak: false)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newTimeReportSegue" {
            guard let newTimeReportVC = segue.destination as? NewTimeReportTVC else { return }
            newTimeReportVC.breakTime = secondsToHoursMinutesSeconds(seconds: Int(totalBreakTime))
            newTimeReportVC.startTime = startTime
            newTimeReportVC.endTime = finishedTime
        }
    }
    
    // MARK: - IB Actions
    @IBAction func startTimerPressed(_ sender: Any) {
        activateTimer()
    }
    
    @IBAction func BreakBtnPressed(_ sender: Any) {
        if !breakIsActive {
            startBreakTime = Date()
        }
        breakIsActive = !breakIsActive
        saveUserDefaults()
        activateBreak()
    }
    
    // MARK: - Functions
    func activateTimer() {
        if isActive {
            // If timer is active - stop the timer
            // show popup asking for action
            activeLogView.isHidden = true
            isActive = false
            startTimerBtn.setTitle(startTimerString, for: .normal)
            
            breakBtn.isEnabled = false
            breakBtn.alpha = 0.5
            
            //Calculate total time since timer started
            finishedTime = Date()
            let resultTime = finishedTime.timeIntervalSince(startTime)
            let (resultH,resultM) = secondsToHoursMinutesSeconds(seconds: Int(resultTime))
            
            //Calculate break time
            let (breakH,breakM) = secondsToHoursMinutesSeconds(seconds: Int(totalBreakTime))
            
            //Show alert after timer has stopped
            let alert = UIAlertController(title: NSLocalizedString("Timer has been stopped", comment: "Timer has been stopped"), message: NSLocalizedString("Working time: ", comment: "Working time: ") + "\(resultH)" + NSLocalizedString(" hours and ", comment: " hours and ") + "\(resultM)" + NSLocalizedString(" minutes.", comment: " minutes.") + "\n" + NSLocalizedString("Break time: ", comment: "Break time: ") + "\(breakH)" + NSLocalizedString(" hours and ", comment: " hours and ") + "\(breakM)" + NSLocalizedString(" minutes.", comment: " minutes."), preferredStyle: .actionSheet)
            //Alert text reads:
            //Working time: XX hours and XX minutes. \nBreak time: XX hours and XX minutes.
            
            // Discard action
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("Discard", comment: "Discard"), style: .destructive, handler: { (action) in
                
                let alertVC = UIAlertController(title: NSLocalizedString("Are you sure?", comment: "Are you sure?"), message: NSLocalizedString("Do you want to discard current timer?", comment: "Do you want to discard current timer?"), preferredStyle: .alert)
                let discardAction = UIAlertAction(title: NSLocalizedString("Discard", comment: "Discard"), style: .destructive) { (alert) in
                    self.resetData()
                    //Reset badge
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { (alert) in
                    self.continueTimer(isBreak: false)
                })
                alertVC.addAction(discardAction)
                alertVC.addAction(cancelAction)
                self.present(alertVC, animated: true, completion: nil)
            }))
            
            // Register timer
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("Register", comment: "Register"), style: .default, handler: {(action) in
                //Reset badge
                UIApplication.shared.applicationIconBadgeNumber = 0
                self.performSegue(withIdentifier: "newTimeReportSegue", sender: self)
            }))
            
            // Continue timer
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("Continue timer", comment: "Continue timer"), style: .cancel, handler: {
                (action) in
                self.continueTimer(isBreak: false)
            }))
            
            present(alert, animated: true)
            
        } else {
            // If timer is inactive - start the timer
            // Make the red bar appear and pulsate
            isActive = true
            startTime = Date()
            
            saveUserDefaults()
            
            activeLogView.isHidden = false
            startTimeLbl.text = startedString + "\(dateFormatter.string(from: startTime))"
            pulsate(view: activeLogView)
            startTimerBtn.setTitle(stopTimerString, for: .normal)
            
            //Activate the break button
            breakBtn.isEnabled = true
            breakBtn.alpha = 1
            
            //Set badge to 1 to indicate activity
            UIApplication.shared.applicationIconBadgeNumber = 1
        }
    }
    
    func activateBreak() {
        if breakIsActive {
            // This is executed if the break timer is being started
            if !pushActive {
                PushManager.shared.sendTimedPush(in: 3600, title: "1 hour break has passed", body: "Don't forget to finish it when your are off your break!", badgeNr: 1)
                pushActive = true
                saveUserDefaults()
            }
            
            startTimerBtn.isEnabled = false
            startTimerBtn.alpha = 0.5
            startTimerBtn.setTitle(stopTimerString, for: .normal)
            activeLogView.backgroundColor = UIColor(red: 114/255, green: 175/255, blue: 207/255, alpha: 1)
            breakBtn.setTitle(stopBreakString, for: .normal)
            registrationLbl.text = breakActiveString
            startTimeLbl.text = startedString + dateFormatter.string(from: startBreakTime)
        } else {
            // This is exectued to stop the break timer
            activeLogView.backgroundColor = UIColor(red: 230/255, green: 32/255, blue: 68/255, alpha: 1)
            registrationLbl.text = registrationActiveString
            breakBtn.setTitle(startBreakString, for: .normal)
            startTimerBtn.isEnabled = true
            startTimerBtn.alpha = 1
            startTimerBtn.setTitle(stopTimerString, for: .normal)
            let finishedTime = Date()
            let resultBreak = finishedTime.timeIntervalSince(startBreakTime)
            totalBreakTime += resultBreak
            PushManager.shared.stopUpcominPush()
            pushActive = false
            saveUserDefaults()
            continueTimer(isBreak: false)
            
        }
    }
    
    func continueTimer(isBreak: Bool) {
        // This is executed if the user wants to continue after pressing "stop timer"
        activeLogView.isHidden = false
        if isBreak {
            startTimeLbl.text = startedString + dateFormatter.string(from: startBreakTime)
        } else {
            isActive = true
            startTimeLbl.text = startedString + dateFormatter.string(from: startTime)
        }
        pulsate(view: activeLogView)
        startTimerBtn.setTitle(stopTimerString, for: .normal)
        
        //Activate the break button
        breakBtn.isEnabled = true
        breakBtn.alpha = 1
        
        if breakIsActive {
            activateBreak()
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60)
    }
    
    //MARK: - User Defaults
    func resetData() {
        startBreakTime = Date()
        totalBreakTime = 0
        clearUserDefaults()
    }
    
    func saveUserDefaults() {
        UserDefaults.standard.set(totalBreakTime, forKey: userDefBreak)
        UserDefaults.standard.set(breakIsActive, forKey: userDefBreakBool)
        UserDefaults.standard.set(startTime, forKey: userDefTimer)
        UserDefaults.standard.set(startBreakTime, forKey: userDefStartBreak)
        UserDefaults.standard.set(pushActive, forKey: userDefPushActive)
    }
    
}

