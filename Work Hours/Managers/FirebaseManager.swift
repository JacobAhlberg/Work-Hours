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
//        let userRef = db.collection("users").document(uid)
        
    }
    
    func fetchCustomers() {
        
//        guard let uid = user?.uid else { return }
    }
    
    func saveData(data : [String: Any?] ,handler: @escaping () -> ()) {
        let timeReportRef = db.collection("timeReports")
        timeReportRef.addDocument(data: data)
    }
}








