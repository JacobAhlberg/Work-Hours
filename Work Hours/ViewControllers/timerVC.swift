//
//  timerVC.swift
//  Work Hours
//
//  Created by Giovanni Palusa on 2018-02-10.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit

class timerVC: UIViewController {
    
    //MARK: IB outlets
    @IBOutlet weak var activeLogView: UIView!
    @IBOutlet weak var startTimerBtn: outlinedButton!
    @IBOutlet weak var breakBtn: outlinedButton!
    
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var registrationLbl: UILabel!
    
    //MARK: class variables
    var isActive = false
    var startTime: Date = Date()
    var breakIsActive: Bool = false
    var startBreakTime: Date = Date(timeIntervalSince1970: 0)
    var totalBreakTime : Double = 0
    
    let dateFormatter = DateFormatter()
    var restoredBreak = false
    
    //MARK: Strings that are being used multiple times
    let stopTimerString = NSLocalizedString("STOP TIMER", comment: "STOP TIMER")
    let startTimerString = NSLocalizedString("START TIMER", comment: "START TIMER")
    
    let userDefTimer = "timerStartValue"
    let userDefBreak = "totalBreakTime"
    let userDefBreakBool = "breakBool"
    let userDefStartBreak = "breakStart"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activeLogView.isHidden = true
        breakBtn.isEnabled = false
        breakBtn.alpha = 0.5
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        totalBreakTime = UserDefaults.standard.double(forKey: userDefBreak)
        breakIsActive = UserDefaults.standard.bool(forKey: userDefBreakBool)
        if let defaultsStartBreakTime = UserDefaults.standard.object(forKey: userDefStartBreak) {
            startBreakTime = defaultsStartBreakTime as! Date
        }
        
        // Get user defaults
        if let defaultsDate = UserDefaults.standard.object(forKey: userDefTimer) {
            startTime = defaultsDate as! Date
            if startTime < Date() {
                isActive = true
                restoredBreak = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if breakIsActive {
            continueTimer(isBreak: true)
        } else {
            continueTimer(isBreak: false)
        }
    }
    
    //MARK: - IB Actions
    @IBAction func startTimerPressed(_ sender: Any) {
        activateTimer()
    }
    
    @IBAction func BreakBtnPressed(_ sender: Any) {
        breakIsActive = !breakIsActive
        saveUserDefaults()
        activateBreak()
    }
    
    //MARK: - Functions
    func activateTimer() {
        if isActive {
            // If timer is active - stop the timer
            // show popup asking for action
            activeLogView.isHidden = true
            isActive = false
            startTimerBtn.setTitle(startTimerString, for: .normal)
            
            //Calculate total time since timer started
            let finishedTime = Date()
            let resultTime = finishedTime.timeIntervalSince(startTime)
            let (resultH,resultM) = secondsToHoursMinutesSeconds(seconds: Int(resultTime))
            
            //Calculate break time
            let (breakH,breakM) = secondsToHoursMinutesSeconds(seconds: Int(totalBreakTime))
            
            //Show alert after timer has stopped
            let alert = UIAlertController(title: "Timer has been stopped", message: "Working time: \(resultH) hours and \(resultM) minutes. \nBreak time: \(breakH) hours and \(breakM) minutes.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction.init(title: "Discard", style: .destructive, handler: { (action) in
                self.resetData()
                
            }))
            alert.addAction(UIAlertAction.init(title: "Continue timer", style: .default, handler: {
                (action) in
                self.continueTimer(isBreak: false)
            }))
            
            alert.addAction(UIAlertAction.init(title: "Register", style: .default, handler: {(action) in
                self.resetData() // Clear time User Defaults
                self.performSegue(withIdentifier: "newTimeReportSegue", sender: self)
            }))
            present(alert, animated: true)
            
        } else {
            // If timer is inactive - start the timer
            // Make the red bar appear and pulsate
            isActive = true
            startTime = Date()
            
            saveUserDefaults()
            
            activeLogView.isHidden = false
            startTimeLbl.text = "Started: \(dateFormatter.string(from: startTime))"
            pulsate(view: activeLogView)
            startTimerBtn.setTitle(stopTimerString, for: .normal)
            
            //Activate the break button
            breakBtn.isEnabled = true
            breakBtn.alpha = 1
        }
    }
    
    func activateBreak() {
        if breakIsActive {
            // This is executed if the break timer is being started
            if restoredBreak {
                startBreakTime = Date()
                saveUserDefaults()
            }
            startTimerBtn.isEnabled = false
            startTimerBtn.alpha = 0.5
            activeLogView.backgroundColor = UIColor(red: 114/255, green: 175/255, blue: 207/255, alpha: 1)
            breakBtn.setTitle(NSLocalizedString("STOP BREAK", comment: "STOP BREAK"), for: .normal)
            startTimeLbl.text = NSLocalizedString("Break started: \(dateFormatter.string(from: Date()))", comment: "Started: [date inserted here]")
            registrationLbl.text = NSLocalizedString("Break is active", comment: "Break is active")
            startTimerBtn.setTitle(stopTimerString, for: .normal)
            isActive = true
        } else {
            // This is exectued to stop the break timer
            activeLogView.backgroundColor = UIColor(red: 230/255, green: 32/255, blue: 68/255, alpha: 1)
            registrationLbl.text = NSLocalizedString("Registration is active", comment: "Registration is active")
            breakBtn.setTitle(NSLocalizedString("START BREAK", comment: "START BREAK"), for: .normal)
            startTimerBtn.isEnabled = true
            startTimerBtn.alpha = 1
            restoredBreak = false
            let finishedTime = Date()
            let resultBreak = finishedTime.timeIntervalSince(startBreakTime)
            totalBreakTime += resultBreak
            saveUserDefaults()
            startTimerBtn.setTitle(stopTimerString, for: .normal)
            continueTimer(isBreak: false)
        }
    }

    func continueTimer(isBreak: Bool) {
        // This is executed if the user wants to continue after pressing "stop timer"
        activeLogView.isHidden = false
        if isBreak {
            startTimeLbl.text = NSLocalizedString("Started break: \(dateFormatter.string(from: startBreakTime))", comment: "Started: [date inserted here]")
        } else {
            isActive = true
            startTimeLbl.text = "Started time: \(dateFormatter.string(from: startTime))"
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
        UserDefaults.standard.set(nil, forKey: self.userDefTimer)
        UserDefaults.standard.set(nil, forKey: self.userDefBreak)
        UserDefaults.standard.set(nil, forKey: self.userDefBreakBool)
        UserDefaults.standard.set(nil, forKey: self.userDefStartBreak)
        
        startBreakTime = Date(timeIntervalSince1970: 0)
        totalBreakTime = 0
    }
    
    func saveUserDefaults() {
        UserDefaults.standard.set(totalBreakTime, forKey: userDefBreak)
        UserDefaults.standard.set(breakIsActive, forKey: userDefBreakBool)
        UserDefaults.standard.set(startTime, forKey: userDefTimer)
        UserDefaults.standard.set(startBreakTime, forKey: userDefStartBreak)
    }
    
}
