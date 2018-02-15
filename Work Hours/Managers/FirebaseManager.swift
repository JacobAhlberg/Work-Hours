//
//  FirebaseManager.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {
    static var instance = FirebaseManager()
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    func fetchTimeReports() {
        guard let uid = user?.uid else { return }
        let customersRef = db.collection("customers")
//        customersRef.whereField(<#T##field: String##String#>, isEqualTo: <#T##Any#>)
        
    }
    
    func fetchCustomers() {
        guard let uid = user?.uid else { return }
        let customersRef = db.collection("customers")
        
    }
    
    func saveData(data : [String: Any?] ,handler: @escaping () -> ()) {
        let timeReportRef = db.collection("timeReports")
        timeReportRef.addDocument(data: data)
    }
}








