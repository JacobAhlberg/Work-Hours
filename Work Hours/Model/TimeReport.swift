//
//  TimeReport.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import Foundation
import MapKit

struct TimeReport {
    private(set) public var abscent: Bool?
    private(set) public var title: String?
    private(set) public var date: Date?
    private(set) public var startTime: Date?
    private(set) public var endTime: Date?
    private(set) public var breakTime: Double?
    private(set) public var customer: String?
    private(set) public var location: CLLocation?
    private(set) public var notes: String?
    private(set) public var images: [String]?
    
    init(data: [String : Any]) {
        abscent = data["abscent"] as? Bool
        title = data["title"] as? String
        date = data["date"] as? Date
        startTime = data["startTime"] as? Date
        endTime = data["endTime"] as? Date
        breakTime = data["breakTime"] as? Double
        customer = data["customer"] as? String
        location = data["location"] as? CLLocation
        notes = data["notes"] as? String
        images = data["images"] as? [String]
    }
}


