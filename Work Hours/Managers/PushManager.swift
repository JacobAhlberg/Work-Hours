//
//  PushManager.swift
//  Work Hours
//
//  Created by Giovanni Palusa on 2018-02-11.
//  Copyright © 2018 Giovanni Palusa. All rights reserved.
//

import Foundation
import UserNotifications

class PushManager: NSObject {
    static var shared = PushManager()
    
    let center = UNUserNotificationCenter.current()
    
    // Call this to request push authorization
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // Authorization was granted
                // make print here to debug
            }
        }
    }
    
    func sendTimedPush(in time: TimeInterval, title: String, body: String, badgeNr: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.sound = .default()
        content.badge = badgeNr as NSNumber
        
        // Trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        let request = UNNotificationRequest(identifier: "Timed push", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // Authorization was granted
                // make print here to debug
            }
        }
    }
    
    func stopUpcominPush() {
        center.removeAllPendingNotificationRequests()
    }
    
    func removeDeliveredPush() {
        center.removeAllDeliveredNotifications()
    }
}


