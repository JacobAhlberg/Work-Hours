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
    
    // call this to request push authorization
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if error == nil {
                //Authorization was granted
                // make print here to debug
            }
        }
    }
    
    func sendTimedPush(in time: TimeInterval, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.sound = .default()
        //to add badge: content.badge should equal some Int
        
        //trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        let request = UNNotificationRequest(identifier: "Timed push", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error == nil {
                // Managed to schedule successfully
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


