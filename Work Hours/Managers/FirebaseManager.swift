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
    
    func fetchTimeReports(handler: @escaping ([TimeReport]) -> ()) {
        
        var fetchedReports: [TimeReport] = []
        guard let uid = user?.uid else { return }
        let reportsRef = db.collection("timeReports")
        reportsRef.whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let report = TimeReport(data: document.data())
                    fetchedReports.append(report)
                }
            }
            handler(fetchedReports)
        }
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








